signature TermParse =
sig

  type term = Term.term
  type hol_type = Type.hol_type
  type grammar = term_grammar.grammar
  type tygrammar = type_grammar.grammar
  type absyn = Absyn.absyn
  type preterm = Preterm.preterm
  type 'a quotation = 'a Portable.frag list
  type pprinters = ((term -> string) * (hol_type -> string)) option
  type 'a in_env = (Pretype.Env.t, 'a) optmonad.optmonad

  (* standard transformations *)
  val absyn : grammar -> tygrammar -> term quotation -> absyn
  val preterm : grammar -> tygrammar -> term quotation -> preterm in_env
  val absyn_to_preterm : grammar -> absyn -> preterm in_env
  val absyn_to_preterm_in_env : grammar -> absyn -> Parse_support.preterm_in_env
  val absyn_to_term : pprinters -> grammar -> absyn -> term
  val preterm_to_term : pprinters -> preterm -> term Preterm.errM
  val term : pprinters -> grammar -> tygrammar -> term quotation -> term

  (* in contexts *)
  val ctxt_preterm_to_term : pprinters -> term list -> preterm -> term
  val ctxt_term : pprinters -> grammar -> tygrammar -> term list ->
                  term quotation -> term

end
