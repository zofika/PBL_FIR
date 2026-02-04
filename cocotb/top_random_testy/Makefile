# Optional: works on environments that have GNU make.
TOPLEVEL = pbl_TOP
MODULE   = test_top_random

VERILOG_SOURCES = \
  $(PWD)/../../src/*.sv

SIM = icarus
IVERILOG_ARGS = -g2012

export COCOTB_SIM_VCD=1

include $(shell cocotb-config --makefiles)/Makefile.sim
