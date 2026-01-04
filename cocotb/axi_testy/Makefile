TOPLEVEL = AXI_main
MODULE   = test_axi

VERILOG_SOURCES = \
  $(PWD)/../../src/AXI_main.sv \
  $(PWD)/../../src/axi.sv \
  $(PWD)/../../src/ram.sv \
  $(PWD)/../../src/multiplekser.sv

SIM = icarus
IVERILOG_ARGS = -g2012 + vcd

# w Makefile lub komendzie sim
# SIM_ARGS=+vcd

IVERILOG_ARGS += -DCOCOTB_SIM

# export COCOTB_SIM_WAVEFORM=vcd
export COCOTB_SIM_VCD=1


include $(shell cocotb-config --makefiles)/Makefile.sim



# TOPLEVEL = AXI_main
# MODULE   = test_axi

# # ścieżki WZGLĘDNE do RTL
# VERILOG_SOURCES = \
#   $(PWD)/../src/AXI_main.sv

# SIM = icarus

# include $(shell cocotb-config --makefiles)/Makefile.sim
