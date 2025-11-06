# Directory definitions
LIB_DIR = "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/verilog/tcbn65lpbwp7t_141a/tcbn65lpbwp7t.v" "/usr/local/cadence/kits/tsmc/beLibs/65nm/TSMCHOME/digital/Front_End/verilog/tphn65lpnv2od3_sl_200a/tphn65lpnv2od3_sl.v" 
SRC_DIR = ../SRC

# File definitions
TESTBENCH = ./memtest_tb.sv
DUT_SRCS = $(SRC_DIR)/memtest.sv $(SRC_DIR)/counter.sv $(SRC_DIR)/PRBS.sv $(SRC_DIR)/control.sv ../ts1n65lpll32x32m4_220a/VERILOG/ts1n65lpll32x32m4_220a_tt1p2v25c.v

# Run simulation with SDF annotation
run: 
	ncverilog $(LIB_DIR)
	ncverilog -sv $(DUT_SRCS) $(TESTBENCH) +sdf_verbose +access+rwc

# View waveforms (assuming .trn or .shm output)
waves:
	gtkwave waveform.vcd &

# Clean generated files
clean:
	rm -rf INCA_libs *.log *.trn *.shm *.history *.X $(WAVE_DIR)/* xcelium* .simvision

.PHONY: all compile elaborate run view clean
