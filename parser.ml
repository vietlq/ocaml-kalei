let binop_precedence:(char, int) Hashtbl.t = Hashtbl.create 10

let precedence c = try Hashtbl.find binop_precedence c with Not_found -> -1

(* From token to AST *)
let rec parse_primary = parser
	(* Numeric value *)
	| [< 'Token.Number n >] -> Ast.Number n
	(* Parse an expression inside parentheses *)
	| [< 'Token.Kwd '('; e=parse_expr; 'Token.Kwd ')' ?? "Expected ')'">] -> e
	(* It could be a variable or a function call *)
  | [< 'Token.Ident id; stream >] ->
      let rec parse_args accumulator = parser
        | [< e=parse_expr; stream >] ->
            begin parser
              | [< 'Token.Kwd ','; e=parse_args (e :: accumulator) >] -> e
              | [< >] -> e :: accumulator
            end stream
        | [< >] -> accumulator
      in
      let rec parse_ident id = parser
        (* Call. *)
        | [< 'Token.Kwd '(';
             args=parse_args [];
             'Token.Kwd ')' ?? "expected ')'">] ->
            Ast.Call (id, Array.of_list (List.rev args))

        (* Simple variable ref. *)
        | [< >] -> Ast.Variable id
      in
      parse_ident id stream
	(* Throw an error *)
	| [< >] -> raise (Stream.Error "Unknown token when expecting an expression.")

and parse_bin_rhs expr_prec lhs stream =
	match Stream.peek stream with
	| Some (Token.Kwd c) when Hashtbl.mem binop_precedence c ->
		let token_prec = precedence c in
		if token_prec < expr_prec then lhs else begin
			Stream.junk stream;
			let rhs = parse_primary stream in
			let rhs = match Stream.peek stream with
				| Some (Token.Kwd c2) ->
					let next_prec = precedence c2 in
					if token_prec < next_prec
					then parse_bin_rhs (token_prec + 1) rhs stream
					else rhs
				| _ -> rhs
			in
			let lhs = Ast.Binary (c, lhs, rhs) in
			parse_bin_rhs expr_prec lhs stream
		end
	| _ -> lhs

and parse_expr = parser
	| [< lhs=parse_primary; stream >] -> parse_bin_rhs 0 lhs stream

let parse_prototype =
	let rec parse_args accumulator = parser
		| [< 'Token.Ident id; e=parse_args (id :: accumulator) >] -> e
		| [< >] -> accumulator
	in
	parser
	| [< 'Token.Ident id;
		'Token.Kwd '(' ?? "Expected '(' in prototype";
		args=parse_args [];
		'Token.Kwd ')' ?? "Expected ')' in prototype" >] ->
		Ast.Prototype (id, Array.of_list (List.rev args))
	| [< >] -> raise (Stream.Error "Expected function name in prototype.")

let parse_definition = parser
	| [< 'Token.Def; p=parse_prototype; e=parse_expr >] -> Ast.Function (p, e)

let parse_toplevel = parser
	(* Anonymous function call *)
	| [< e=parse_expr >] -> Ast.Function (Ast.Prototype ("", [||]), e)

let parse_extern = parser
	| [< 'Token.Extern; e=parse_prototype >] -> e
