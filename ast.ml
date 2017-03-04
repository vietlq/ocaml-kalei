type expr =
  (* Numeric value *)
  | Number of float
  (* Variable *)
  | Variable of string
  (* Binary operator *)
  | Binary of char * expr * expr
  (* Function call *)
  | Call of string * expr array

(* Function prototype/signature *)
type proto = Prototype of string * string array

(* Function definition *)
type func = Function of proto * expr
