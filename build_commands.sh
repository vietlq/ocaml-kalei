ocamldep.opt -modules toy.ml > toy.ml.depends
ocamldep.opt -pp camlp4of -modules lexer.ml > lexer.ml.depends
ocamldep.opt -modules token.ml > token.ml.depends
ocamlc.opt -c -o token.cmo token.ml
ocamldep.opt -pp camlp4of -modules parser.ml > parser.ml.depends
ocamldep.opt -modules ast.ml > ast.ml.depends
ocamlc.opt -c -o ast.cmo ast.ml
ocamldep.opt -modules toplevel.ml > toplevel.ml.depends
ocamlc.opt -c -I /usr/local/lib/ocaml/camlp4 -pp camlp4of -o parser.cmo parser.ml
ocamlc.opt -c -I /usr/local/lib/ocaml/camlp4 -pp camlp4of -o lexer.cmo lexer.ml
ocamlc.opt -c -o toplevel.cmo toplevel.ml
ocamlc.opt -c -o toy.cmo toy.ml
ocamlopt.opt -c -o token.cmx token.ml
ocamlopt.opt -c -o ast.cmx ast.ml
ocamlopt.opt -c -I /usr/local/lib/ocaml/camlp4 -pp camlp4of -o parser.cmx parser.ml
ocamlopt.opt -c -I /usr/local/lib/ocaml/camlp4 -pp camlp4of -o lexer.cmx lexer.ml
ocamlopt.opt -c -o toplevel.cmx toplevel.ml
ocamlopt.opt -c -o toy.cmx toy.ml
ocamlopt.opt ast.cmx token.cmx lexer.cmx parser.cmx toplevel.cmx toy.cmx -o toy.native
