#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Uruchomienie testow CDC (bez cocotb, iverilog+vvp)"""

import os
import subprocess
import sys

cdc_test_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(cdc_test_dir)

src_dir = os.path.normpath(os.path.join(cdc_test_dir, '../../src'))
cdc_module = os.path.join(src_dir, 'cdc.sv')
cdc_tb = os.path.join(src_dir, 'tb', 'cdc_tb.sv')

print("=" * 70)
print("TESTY IVERILOG/VVP DLA MODULU CDC")
print("=" * 70)
print(f"\nModul CDC: {cdc_module}")
print(f"Testbench: {cdc_tb}")

# Kompilacja
print("\n[1] Kompilacja...")
compile_cmd = ['iverilog', '-o', 'cdc_test.vvp', cdc_tb, cdc_module]

result = subprocess.run(compile_cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"BLAD kompilacji:\n{result.stderr}")
    sys.exit(1)
print("OK - Skompilowano")

# Symulacja
print("\n[2] Symulacja...")
print("-" * 70)

result = subprocess.run(['vvp', 'cdc_test.vvp'], capture_output=False, text=True)

print("-" * 70)
if result.returncode == 0:
    print("\nOK - TESTY ZAKONCZONE POMYSLNIE")
    if os.path.exists('cdc_tb.vcd'):
        print("VCD dostepny: cdc_tb.vcd")
        print("  Otworz: gtkwave cdc_tb.vcd")
else:
    print(f"\nBLAD (kod {result.returncode})")

print("=" * 70)
