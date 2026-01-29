# Makefile dla testów cocotb CDC

# Ścieżki
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Katalogi
PWD=$(shell pwd)
SRC_DIR = $(PWD)/../../src

# Pliki SystemVerilog - CDC moduł
VERILOG_SOURCES = $(SRC_DIR)/cdc.sv

# Nazwa modułu top-level w SystemVerilog
TOPLEVEL = cdc_module

# Nazwa modułu testowego Python (bez .py)
MODULE = cdc_tb

# Opcje kompilatora - flaga -g2012 dla SystemVerilog 2012
COMPILE_ARGS = -g2012

# Zmienne środowiska dla cocotb (VCD trace)
export COCOTB_TRACE ?= 1

# Opcje cocotb
COCOTB_RESULTS_FILE = results.xml
COCOTB_REDUCED_LOG_FMT = 1

# Include cocotb makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

# Dodatkowe targety
.PHONY: clean_all wave

# Wyczyść wszystko włącznie z plikami waveform
clean_all: clean
	rm -f *.vcd *.fst *.ghw *.xml

# Otwórz waveform w GTKWave (jeśli istnieje)
wave:
	@if [ -f dump.vcd ]; then \
		gtkwave dump.vcd; \
	elif [ -f dump.fst ]; then \
		gtkwave dump.fst; \
	else \
		echo "No waveform file found"; \
	fi

# Help
help:
	@echo "Available targets:"
	@echo "  make              - Run simulation with default simulator (icarus)"
	@echo "  make SIM=xsim     - Run with Xilinx simulator"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make clean_all    - Clean everything including VCD files"
	@echo "  make wave         - Open waveform in GTKWave"
