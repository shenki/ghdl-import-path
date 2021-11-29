
FILES := a/litedram-initmem.vhdl  b/test.vhdl
TOP := test

test: $(FILES)
	ghdl synth $(FILES) -e $(TOP)

