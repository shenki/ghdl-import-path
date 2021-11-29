
FILES := a/litedram-initmem.vhdl  b/test.vhdl
TOP := litedram_wrapper
OUTOUT := test.json

all:
	yosys  -p " ghdl --std=08 --no-formal $(FILES) -e $(TOP); synth_ecp5 -nowidelut -json $(OUTPUT)  -abc2 -abc9"

