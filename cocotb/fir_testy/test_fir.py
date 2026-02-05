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

    #
    #ram wej - probki
    #ram wyj - wyn
    #ram wsp - wsp

    #1 = 32767
    #-1 = -32768
#==============================================================================
@cocotb.test()
async def fir_test_1(dut):
    # TEST 1
    # wsp rowny 1

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    #1.
    probki = [1000, -2000, 3000, -4000, 0]
    dut.f_ile_probek.value = 4
    wsp = [32767]
    dut.f_ile_wsp.value = 1
    dut.f_ile_razy.value = 4 + 1 - 1 #zeby nie bylo -1....
    y = fir_hw_model(probki, wsp, 4, 1)

    wyn = []
    print(probki)
    print(probki[0])

    dut.f_start.value = 0

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
            # print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))
        await RisingEdge(dut.clk)

    dut.f_start.value = 0

    print("wynik z modelu:", y)
    print(len(wyn))
    print("read data:", wyn)

    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass

@cocotb.test()
async def fir_test_2(dut):
    #TEST 2
    # opoznienie o 1

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    #2, opoxnienie + znak
    probki = [1000, 2000, 3000, 4000, 0]
    dut.f_ile_probek.value = 4
    wsp = [0, 32767]  #-32768
    dut.f_ile_wsp.value = 2
    dut.f_ile_razy.value = 4 + 2 - 1 #zeby nie bylo -1....
    y = fir_hw_model(probki, wsp, 4, 2)

    wyn = []
    print(probki)
    print(probki[0])

    dut.f_start.value = 0

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
            # print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))
        await RisingEdge(dut.clk)

    dut.f_start.value = 0

    print("wynik z modelu:", y)
    print(len(wyn))
    print("read data:", wyn)


    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"

    pass


@cocotb.test()
async def fir_test_3(dut):
    #TEST 3
    # usredniajacy

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

        #4 usrednianie
    probki = [-1000, -2000, -3000, -4000, 0, 0, 0]  #uzupelnic trzeba ten "ram" zerami zeby rozmiar sie zgadzal...(ile_razy)
    dut.f_ile_probek.value = 4
    wsp = [16384, 16384]  #1/2 1/2
    dut.f_ile_wsp.value = 2
    dut.f_ile_razy.value = 4 + 2 - 1 #zeby nie bylo -1....
    y = fir_hw_model(probki, wsp, 4, 2)

    wyn = []
    print(probki)
    print(probki[0])

    dut.f_start.value = 0

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
            # print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))
        await RisingEdge(dut.clk)

    dut.f_start.value = 0

    print("wynik z modelu:", y)
    print(len(wyn))
    print("read data:", wyn) 

    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass

@cocotb.test()
async def fir_test_4(dut):
    #TEST 4
    # rozniczka

    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())


    probki = [1000, 2000, 3000, 2000, 1000, 0]
    dut.f_ile_probek.value = 5
    wsp = [32767, -32768]
    dut.f_ile_wsp.value = 2
    dut.f_ile_razy.value = 5 + 2 - 1 #zeby nie bylo -1....
    y = fir_hw_model(probki, wsp, 5, 2)

    wyn = []
    print(probki)
    print(probki[0])

    dut.f_start.value = 0

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
            # print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))
        await RisingEdge(dut.clk)

    dut.f_start.value = 0

    print("wynik z modelu:", y)
    print(len(wyn))
    print("read data:", wyn)

    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass

@cocotb.test()
async def fir_test_5(dut):
    #TEST 5
    # losowe dane - dlugo liczy...
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    ile_probek = random.randint(1, 4000)
    ile_wsp = random.randint(1, 32)
    
    dut.f_ile_probek.value = ile_probek
    wsp = [random.randint(-16384, 16383) for _ in range(ile_wsp)]
    dut.f_ile_wsp.value = ile_wsp
    ile_razy = ile_probek + ile_wsp - 1 
    dut.f_ile_razy.value = ile_probek + ile_wsp - 1 #zeby nie bylo -1....
    probki = [random.randint(-8192, 8191) for _ in range(ile_probek)] + [0] * (ile_razy - ile_probek)
    y = fir_hw_model(probki, wsp, ile_probek, ile_wsp)

    wyn = []
    # print(probki)
    # print(probki[0])

    dut.f_start.value = 0

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
        # print("liczenie...")
        dut.f_wsp_data.value = wsp[int(dut.f_adress_fir)]
        # print("xd")
        dut.f_probka.value = probki[int(dut.f_a_probki_fir)]
        if(dut.f_fsm_wyj_wr == 1): 
            wyn.append(to_signed_16bit(dut.f_fir_probka_wynik))
            # print("wynik", to_signed_16bit(dut.f_fir_probka_wynik))
        await RisingEdge(dut.clk)

    dut.f_start.value = 0

#bez wys...
    # print("wynik z modelu:", y)
    print(len(wyn))
    # print("read data:", wyn)

    assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass