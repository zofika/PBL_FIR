TOPLEVEL = pbl_TOP
MODULE   = testy_top

VERILOG_SOURCES = \
  $(PWD)/../../src/pbl_TOP.sv \
  $(PWD)/../../src/AXI_main.sv \
  $(PWD)/../../src/axi.sv \
  $(PWD)/../../src/ram.sv \
  $(PWD)/../../src/multiplekser.sv \
  $(PWD)/../../src/FIR_main.sv \
  $(PWD)/../../src/fsm.sv \
  $(PWD)/../../src/licznik.sv \
  $(PWD)/../../src/licznik_petli.sv \
  $(PWD)/../../src/shift_R.sv \
  $(PWD)/../../src/multiplier.sv \
  $(PWD)/../../src/adder.sv \
  $(PWD)/../../src/acc.sv

SIM = icarus
IVERILOG_ARGS = -g2012 + vcd


IVERILOG_ARGS += -DCOCOTB_SIM

# export COCOTB_SIM_WAVEFORM=vcd
export COCOTB_SIM_VCD=1


include $(shell cocotb-config --makefiles)/Makefile.sim

#######################