.PHONY: all clean

all:
	ocamlbuild toy.native

clean:
	$(OCB) -clean
	rm -rf *.o *.a *.lib
	rm -rf *.cmi *.cmx *.cma *.cmxa
	rm -rf *.byte *.native _build
