signature hhExportTf1 =
sig

include Abbrev

  type thmid = string * string
  val tf1_write_pb : string -> (thmid * (string list * thmid list)) -> unit
  val tf1_export_bushy : string -> string list -> unit
  val tf1_export_chainy : string -> string list -> unit

end
