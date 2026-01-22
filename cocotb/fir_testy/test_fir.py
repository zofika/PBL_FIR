import sys
import os
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0,PROJECT_ROOT)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random

from modelFIR.model_fir import fir_hw_model

##################################################################
# make SIM=icarus WAVES=1 TESTCASE=fir_test_1

# /home/lukas/PBL_projekt_github/PBL_FIR/cocotb# make SIM=icarus WAVES=1 TESTCASE=axi_test_1
##################################################################

def to_signed_16bit(obj):
    raw = int(obj.value) 
    if raw > 32767:
        return raw - 65536
    return raw

@cocotb.test()
async def fir_test_1(dut):
    # TEST 1
    # 

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    #
    #ram wej - probki
    #ram wyj - wyn
    #ram wsp - wsp
    #probki = {0: 0xAA, 1: 0xBB, 2: 0xCC}

    #1. 
    # probki = [1000, -2000, 3000, -4000]
    # wsp = [-32768]

    #2, 
    probki = [1000, 2000, 3000, 4000, 0]
    dut.f_ile_probek.value = 4
    wsp = [0, -32768]
    dut.f_ile_wsp.value = 2
    dut.f_ile_razy.value = 4 + 2 - 1 #zeby nie bylo -1....
    y = fir_hw_model(probki, wsp, 4, 2)

    #3
    # probki = [1000, 2000, 3000, 2000, 1000, 0]
    # dut.f_ile_probek.value = 5
    # wsp = [32768, -32768]
    # dut.f_ile_wsp.value = 2
    # dut.f_ile_razy.value = 5 + 2 - 1 #zeby nie bylo -1....
    # y = fir_hw_model(probki, wsp, 5, 2)

    wyn = []
    print(probki)
    print(probki[0])

    #synaly - to wszsytko z rej_ster jest
    # dut.f_ile_probek.value = len(probki)
    # dut.f_ile_wsp.value = len(wsp)
    # dut.f_ile_razy.value = len(probki) + len(wsp) - 1 #zeby nie bylo -1....

    dut.f_start.value = 0
    print(len(wsp))

    print(wsp)

    dut.rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.rst_n.value = 1

    print(int(dut.f_ile_probek))

    #FIR
    xd = 0
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.f_start.value = 1
    print(int(dut.f_adress_fir))
    for _ in range(1):
        await RisingEdge(dut.clk)
    dut.f_start.value = 0
    while(1):
        if(dut.f_done == 1): break
        # print("addres fir", int(dut.f_adress_fir))
        dut.f_wsp_data.value = wsp[int(dut.f_adress_fir)]
        # print("xd")
        
        dut.f_probka.value = probki[int(dut.f_a_probki_fir)]
        if(dut.f_fsm_wyj_wr == 1): 
            wyn.append(to_signed_16bit(dut.f_fir_probka_wynik))
            print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))

        await RisingEdge(dut.clk)

    dut.f_start.value = 0
    # #model FIR
    # y = fir_hw_model(probki, wsp, len(probki), len(wsp))

    print("wynik z modelu:", y)
    print(len(wyn))

    print("read data:", wyn)


    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass