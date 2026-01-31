import sys
import os
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0,PROJECT_ROOT)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import random

from modelFIR.model_fir import fir_hw_model

from cocotb_bus.drivers.amba import AXI4Master


##################################################################
# make SIM=icarus WAVES=1 TESTCASE=top_test_1

##################################################################

def to_signed_16bit(obj):
    raw = int(obj.value) 
    if raw > 32767:
        return raw - 65536
    return raw

@cocotb.test()
async def top_test_1(dut):
    # TEST 1
    # 
    # 1.zapis probek AXI
    # 1.1. odczyt probek AXI
    # 2. zapis wsp APB
    # 3. zapis do rej ster APB (bez start)
    # 3.1. odczyt wsp + rej APB
    # 4. zapis start APB
    # 5. FIR liczy
    # 6. odczyt DONE APB
    # 7. odczyt probek wyn AXI
    # 8. porowanie z modelemFIR.
#==============================================================================

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())
    #zegar dla apb - wolniejszy

    # APB - wsp, parametry
    ile_probek = 5 #4
    dut.u_fir.f_ile_probek.value = ile_probek
    # wsp = [16384, 16384]  #1/2 1/2
    wsp = [32767, -32768]
    ile_wsp = 2
    dut.u_fir.f_ile_wsp.value = ile_wsp
    ile_razy = 5 + 2 - 1
    dut.u_fir.f_ile_razy.value = ile_razy #zeby nie bylo -1....
    

    # AXI
    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    # AXI zapis probek
    adres = 0x0000       
    N = 5  
    # zapisane_dane = [-1000, -2000, -3000, -4000, 0, 0, 0] #probki
    zapisane_dane = [1000, 2000, 3000, 2000, 1000, 0]
    await axi.write(adres, zapisane_dane, size = 2)

    # APB - start

    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.u_fir.f_start.value = 1  # start
    for _ in range(1):
        await RisingEdge(dut.a_clk)
    dut.u_fir.f_start.value = 0

    # FIR
    while(1):
        if(dut.u_fir.f_done == 1): break
        dut.u_fir.f_wsp_data.value = wsp[int(dut.u_fir.f_adress_fir)]  # to bedzie z apb
        # dut.f_probka.value = probki[int(dut.f_a_probki_fir)  - to juz z axi jest
        # if(dut.f_fsm_wyj_wr == 1): 
        #     wyn.append(to_signed_16bit(dut.f_fir_probka_wynik))  - to juz tez z axi jest
        await RisingEdge(dut.a_clk)  # narazie to potrzebne dla wsp tylko...

    # FIR (jak juz bedzie APB to nawet teo nie bedzie - z apb bedzie odczyt poprostu czy juz jest DONE w petli.


    # AXI odczyt wyniku
    adres = 0x4000 # adres sie zmienia
    wyn = []
    data = await axi.read(adres,length=ile_razy, size = 2)
    for x in data:
        wyn.append(to_signed_16bit(x))

    # modelFIR
    y = fir_hw_model(zapisane_dane, wsp, ile_probek, ile_wsp)

    assert wyn == y, f"Odczytana próbka {wyn} != oczekiwana {y}"
    pass

@cocotb.test()
async def top_test_2(dut):
    # TEST 2
    # 
    # To samo co w TEST 1 ale dwa razy... czyli jak raz sie zrobi to zmiana wsp/probek i odpalenie.
#==============================================================================

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())




    # assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass