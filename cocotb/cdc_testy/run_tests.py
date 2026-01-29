
import sys
import os
os.chdir(r'C:\Users\jessi\OneDrive\Pulpit\studia II\pbl\PBL_FIR\cocotb\cdc_testy')
sys.path.insert(0, r'C:\Users\jessi\OneDrive\Pulpit\studia II\pbl\PBL_FIR\cocotb\cdc_testy')

# Ustaw zmienne œrodowiska
os.environ['COCOTB_SIMULATOR'] = 'icarus'
os.environ['COCOTB_TOPLEVEL'] = 'cdc_module'
os.environ['COCOTB_MODULE'] = 'cdc_tb'
os.environ['COCOTB_VERILOG_SOURCES'] = r'C:\Users\jessi\OneDrive\Pulpit\studia II\pbl\PBL_FIR\src\cdc.sv'
os.environ['COCOTB_TRACE'] = '1'
os.environ['COCOTB_REDUCED_LOG_FMT'] = '1'

import cocotb
from cocotb.runner import get_runner

runner = get_runner('icarus')
runner.build(
    verilog_sources=[r'C:\Users\jessi\OneDrive\Pulpit\studia II\pbl\PBL_FIR\src\cdc.sv'],
    compile_args=['-g2012'],
    build_dir='sim_build'
)
runner.test()
