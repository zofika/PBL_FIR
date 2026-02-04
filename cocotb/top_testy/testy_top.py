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

from cocotbext.apb import ApbMaster, ApbBus


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
    cocotb.start_soon(Clock(dut.apb_PCLK, 20, units="ns").start())

    # APB bus + master - use wrapper to map signals
    bus = ApbBus(dut, "apb")
    apb = ApbMaster(bus, dut.apb_PCLK)

    #resety
    dut.apb_PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.apb_PCLK)
    dut.apb_PRESETn.value = 1
    await RisingEdge(dut.apb_PCLK)

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    # APB - wsp, parametry
    ile_probek = 5 #4
    #100100
    write_task = cocotb.start_soon(apb.write(int(36), ile_probek))
    # dut.u_fir.f_ile_probek.value = ile_probek
    # wsp = [16384, 16384]  #1/2 1/2
    wsp = [32767, -32768]
    write_task = cocotb.start_soon(apb.write(int(0), 32767))
    write_task = cocotb.start_soon(apb.write(int(1), -32767))
    ile_wsp = 2
    # dut.u_fir.f_ile_wsp.value = ile_wsp
    #100011
    write_task = cocotb.start_soon(apb.write(int(35), ile_wsp))
    ile_razy = ile_wsp + ile_wsp - 1
    # dut.u_fir.f_ile_razy.value = ile_razy #zeby nie bylo -1....
    

    # AXI
    # dut.a_rst_n.value = 0
    # for _ in range(5):
    #     await RisingEdge(dut.a_clk)
    # dut.a_rst_n.value = 1

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
    # dut.u_fir.f_start.value = 0 #1  # start
    #100000
    write_task = cocotb.start_soon(apb.write(int(32), 1))
    for _ in range(1):
        await RisingEdge(dut.a_clk)
    # dut.u_fir.f_start.value = 0

    # FIR
    
    while(1):
        # if(dut.u_fir.f_done == 1): break
        koniec = await apb.read(int(33)) #
        if(int.from_bytes(koniec, byteorder="little") == 1): break
        print("liczy dalej")
        # dut.u_fir.f_wsp_data.value = wsp[int(dut.u_fir.f_adress_fir)]  # to bedzie z apb

        # dut.f_probka.value = probki[int(dut.f_a_probki_fir)  - to juz z axi jest
        # if(dut.f_fsm_wyj_wr == 1): 
        #     wyn.append(to_signed_16bit(dut.f_fir_probka_wynik))  - to juz tez z axi jest
        await RisingEdge(dut.a_clk)  # narazie to potrzebne dla wsp tylko...
    print("koniec")
    # FIR (jak juz bedzie APB to nawet teo nie bedzie - z apb bedzie odczyt poprostu czy juz jest DONE w petli.


    # AXI odczyt wyniku
    adres = 0x4000 # adres sie zmienia
    wyn = []
    data = await axi.read(adres,length=6, size = 2)
    for x in data:
        wyn.append(to_signed_16bit(x))

    # modelFIR
    y = fir_hw_model(zapisane_dane, wsp, ile_probek, ile_wsp)
    print("wynik: ",wyn)
    print("z modelu: ",y)
    assert wyn == y, f"Odczytana próbka {wyn} != oczekiwana {y}"
    pass

@cocotb.test()
async def top_test_2(dut):
    # TEST 2
    # 
    # To samo co w TEST 1 ale dwa razy... czyli jak raz sie zrobi to zmiana wsp/probek i odpalenie.
#==============================================================================

    # cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())




    # assert y == wyn, f"Odczytany wynik {wyn} != oczekiwana {y}"
    pass


async def _reset_dut(dut):
    dut.apb_PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.apb_PCLK)
    dut.apb_PRESETn.value = 1
    await RisingEdge(dut.apb_PCLK)

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1
    await RisingEdge(dut.a_clk)


async def _run_one_case(dut, apb, axi, samples, coeffs):
    ile_probek = len(samples)
    ile_wsp = len(coeffs)
    out_len = ile_probek + ile_wsp - 1

    # Program parameters
    await apb.write(int(36), ile_probek)
    for addr, c in enumerate(coeffs):
        await apb.write(int(addr), int(c))
    await apb.write(int(35), ile_wsp)

    # Program input samples via AXI
    await axi.write(0x0000, [int(x) for x in samples], size=2)

    # Start pulse
    await apb.write(int(32), 1)
    await RisingEdge(dut.a_clk)
    await apb.write(int(32), 0)

    # Wait for DONE with a bounded poll loop
    max_cycles = int(os.getenv("TOP_RANDOM_MAX_CYCLES", "5000"))
    for _ in range(max_cycles):
        koniec = await apb.read(int(33))
        if int.from_bytes(koniec, byteorder="little") == 1:
            break
        await RisingEdge(dut.a_clk)
    else:
        raise AssertionError(f"Timeout waiting for DONE after {max_cycles} cycles")

    # Read output samples
    data = await axi.read(0x4000, length=out_len, size=2)
    wyn = [to_signed_16bit(x) for x in data]

    # Compare with model
    exp = fir_hw_model([int(x) for x in samples], [int(c) for c in coeffs], ile_probek, ile_wsp)
    assert wyn == exp, f"Mismatch: got {wyn} expected {exp} (ile_probek={ile_probek}, ile_wsp={ile_wsp})"


@cocotb.test()
async def top_random_test(dut):
    """Randomized regression for the top module.

    Control with env vars:
      TOP_RANDOM_ITERS (default 10)
      TOP_RANDOM_MAX_SAMPLES (default 16)
      TOP_RANDOM_MAX_TAPS (default 8)
    """

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.apb_PCLK, 20, units="ns").start())

    bus = ApbBus(dut, "apb")
    apb = ApbMaster(bus, dut.apb_PCLK)
    axi = AXI4Master(dut, "a", dut.a_clk)

    await _reset_dut(dut)

    iters = int(os.getenv("TOP_RANDOM_ITERS", "10"))
    max_samples = int(os.getenv("TOP_RANDOM_MAX_SAMPLES", "16"))
    max_taps = int(os.getenv("TOP_RANDOM_MAX_TAPS", "8"))
    value_abs = int(os.getenv("TOP_RANDOM_VALUE_ABS", "8000"))

    # Make the sequence reproducible if user passes SEED
    seed_env = os.getenv("SEED")
    if seed_env is not None:
        random.seed(int(seed_env))

    for _i in range(iters):
        # Optionally reset each iteration to keep the test independent
        await _reset_dut(dut)

        ile_probek = random.randint(1, max_samples)
        ile_wsp = random.randint(1, max_taps)

        # Keep magnitudes modest by default to avoid saturation/truncation corner cases.
        samples = [random.randint(-value_abs, value_abs) for _ in range(ile_probek)]
        coeffs = [random.randint(-value_abs, value_abs) for _ in range(ile_wsp)]

        await _run_one_case(dut, apb, axi, samples, coeffs)