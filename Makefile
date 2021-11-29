
FILES := a/litedram-initmem.vhdl  b/test.vhdl
TOP := test
OUTPUT := test.json

test.json: $(FILES)
	yosys  -p " ghdl --std=08 --no-formal $(FILES) -e $(TOP); synth_ecp5 -nowidelut -json $@ -abc2 -abc9"

