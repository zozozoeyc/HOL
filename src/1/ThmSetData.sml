structure ThmSetData :> ThmSetData =
struct

open DB Lib HolKernel

type data = LoadableThyData.t

fun splitnm nm = let
  val comps = String.fields (equal #".") nm
in
  case comps of
    (thy::nm::_) => (thy, nm)
  | [name] => (current_theory(), name)
  | [] => raise Fail "String.fields returns empty list??"
end

fun lookup nm =
    SOME (uncurry DB.fetch (splitnm nm))
    handle HOL_ERR _ =>
           (Feedback.HOL_WARNING "ThmSetData" "lookup"
                                 ("Bad theorem name: " ^ nm);
            NONE)

fun read s =
  SOME (List.mapPartial
            (fn n => Option.map (fn r => (n,r)) (lookup n))
            (String.fields Char.isSpace s))
  handle HOL_ERR _ => NONE

fun writeset set = let
  fun foldthis ((nm,_), acc) = let
    val (thy,nm) = splitnm nm
  in
    (thy^"."^nm)::acc
  end
  val list = List.foldr foldthis [] set
in
  String.concatWith " " list
end

type destfn = data -> (string * thm) list option
val destmap = let
  open Binarymap
in
  ref (mkDict String.compare : (string,destfn) dict)
end

fun all_set_types () = Binarymap.foldr (fn (k,_,acc) => k::acc) [] (!destmap)

fun new s = let
  val (mk,dest) = LoadableThyData.new {merge = op@, read = read,
                                       write = writeset, thydataty = s}
  val _ = destmap := Binarymap.insert(!destmap,s,dest)
  fun foldthis (nm,set) =
      case lookup nm of
        SOME r => (nm, r) :: set
      | NONE => raise mk_HOL_ERR "ThmSetData" "new" ("Bad theorem name: "^nm)
  fun mk' slist =
      let val unencoded = foldl foldthis [] slist
      in
        (mk unencoded, unencoded)
      end
in
  (mk',dest)
end

fun theory_data {settype = key, thy} =
    case Binarymap.peek(!destmap, key) of
      NONE => raise mk_HOL_ERR "ThmSetData" "theory_data"
                    ("No ThmSetData with name "^Lib.quote key)
    | SOME df => let
        open LoadableThyData
      in
        case segment_data {thy = thy, thydataty = key} of
          NONE => []
        | SOME d => valOf (df d)
                    handle Option =>
                    raise mk_HOL_ERR "ThmSetData" "theory_data"
                          ("ThmSetData for name " ^ Lib.quote key ^
                           " doesn't decode")
      end

fun current_data s = theory_data { settype = s, thy = current_theory() }

fun all_data s = map (fn thy => (thy, theory_data {settype = s, thy = thy}))
                     (current_theory() :: ancestry "-")

fun new_exporter name addfn = let
  val (mk,dest) = new name
  open LoadableThyData TheoryDelta
  fun onload thyname =
      case segment_data {thy = thyname, thydataty = name} of
        NONE => ()
      | SOME d => let
          val thms = valOf (dest d)
        in
          addfn thyname (map #2 thms)
        end
  fun revise_data td =
      case segment_data {thy = current_theory(), thydataty = name} of
        NONE => ()
      | SOME d => let
          val alist = valOf (dest d)
          val (ok,notok) = Lib.partition (uptodate_thm o #2) alist
        in
          case notok of
            [] => ()
          | _ => (HOL_WARNING
                      "ThmSetData" "revise_data"
                      ("\n  Theorems in set " ^ Lib.quote name ^
                       ":\n    " ^ String.concatWith ", " (map #1 notok) ^
                       "\n  invalidated by " ^ TheoryDelta.toString td);
                  set_theory_data {thydataty = name,
                                   data = #1 (mk (map #1 ok))})
        end

  fun hook (TheoryLoaded s) = onload s
    | hook (td as DelConstant _) = revise_data td
    | hook (td as DelTypeOp _) = revise_data td
    | hook _ = ()
  fun export s = let
    val (data, namedthms) = mk [s]
    val thms = map #2 namedthms
  in
    addfn (current_theory()) thms;
    write_data_update {thydataty = name, data = data}
  end
in
  register_hook ("ThmSetData.onload." ^ name, hook);
  List.app onload (ancestry "-");
  {export = export, mk = mk, dest = dest}
end


end (* struct *)
