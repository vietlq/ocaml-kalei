let rec main_loop stream =
  match Stream.peek stream with
  | None -> ()
  | Some (Token.Kwd ';') ->
  	Stream.junk stream;
  	main_loop stream
  | Some token ->
  	begin
  		try match token with
  			| Token.Def ->
  				ignore(Parser.parse_definition stream);
  				print_endline "Parsed a function definition.";
  			| Token.Extern ->
  				ignore(Parser.parse_extern stream);
  				print_endline "Parsed an extern.";
  			| _ ->
  				ignore(Parser.parse_toplevel stream);
  				print_endline "Parsed a top-level expr.";
  		with Stream.Error s ->
  			Stream.junk stream;
  			print_endline s;
  	end;
  	print_string "ready> "; flush stdout;
  	main_loop stream
