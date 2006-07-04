(*****************************************************************************)
(* Slurp in defaxioms.lisp.trans.ml and put results on variable defaxioms.   *)
(*****************************************************************************)

new_theory "defaxioms";

use (Globals.HOLDIR ^ "/examples/acl2/ml/load_sexp.ml");
use (Globals.HOLDIR ^ "/examples/acl2/ml/defaxioms.lisp.trans.ml");
load_defaxioms();
val string_abbrev_thms = map snd (definitions "-");

export_acl2_theory();

compile_theory();


