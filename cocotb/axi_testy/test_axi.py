import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb_bus.drivers.amba import AXI4Master
import random

##################################################################
# make SIM=icarus WAVES=1 TESTCASE=axi_test_1

# /home/lukas/PBL_projekt_github/PBL_FIR/cocotb# make SIM=icarus WAVES=1 TESTCASE=axi_test_1

#bez tego TESTCASE odpala wszystko naraz
#i nie ogarniam jak odpalic wykresy vcd. ale jest .fst i wystarczy odpalic gtkwave i ten plik przerzucic
##################################################################

@cocotb.test()
async def axi_test_1(dut):
    # TEST 1
    # Zapis pojedynczej probki do RAM wej i odczyt jej

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    #adres dla RAM wej -> przedzial jest 14bitowy 
    adres = 0x3000
    val = [0xDEAD]

    await axi.write(adres, val, size = 2)
    print("write data:", val)

    results = []

    data = await axi.read(adres,length=1, size = 2)

    for sample in data:
        val_r = int(str(sample), 2)
        results.append(val_r)
        # print(f"Próbka: {hex(val_r)}")
    print("read data:", results)

    assert results == val, f"Odczytana próbka {results} != oczekiwana {val}"
    pass
@cocotb.test()
async def axi_test_2(dut):
    # TEST 2
    # Zapis pojedynczej losowej probki pod losowy adres do RAM wej i odczyt jej

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    #adres dla RAM wej -> przedzial jest 14bitowy parzysty(co 2) 0,2,4,6,.....
    # adres = 0x3000
    adres = random.randint(0,8191)
    adres = adres * 2
    # val = [0xDEAD]
    val = [random.randint(0,0xFFFF)]

    await axi.write(adres, val, size = 2)
    print("write data:", val)

    results = []

    data = await axi.read(adres,length=1, size = 2)

    for sample in data:
        val_r = int(str(sample), 2)
        results.append(val_r)
        # print(f"Próbka: {hex(val_r)}")
    print("read data:", results)

    assert results == val, f"Odczytana próbka {results} != oczekiwana {val}"
    pass
# TEST 3
# Zapis N losowyc probek pod losowe adresy do RAM wej i odczyt ich
@cocotb.test()
async def axi_test_3(dut):
    # TEST 3
    # Zapis N losowyc probek pod losowe adresy do RAM wej i odczyt ich

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    #adres dla RAM wej -> przedzial jest 14bitowy parzysty(co 2) 0,2,4,6,.....
    
    N = 100
    zapisane_dane = {}
    for i in range(N):
        adres = random.randint(0,8191)
        adres = adres * 2
        # val = [0xDEAD]
        val = [random.randint(0,0xFFFF)]
        zapisane_dane[adres] = val
        await axi.write(adres, val, size = 2)
        # print("write data:", adres, val)

    # ===
    results = []
    for addr, poprawna_dana in zapisane_dane.items():
        data = await axi.read(addr,length=1, size = 2)
        # data = int(data[0], 2)
        assert data == poprawna_dana, f"Odczytana próbka {addr, data} != oczekiwana {addr, poprawna_dana}"

    pass
@cocotb.test()
async def axi_test_4(dut):
    # TEST 4
    # BURST: Zapis N losowyc probek pod jakies jedne z poczatkowych adresy do RAM wej i odczyt ich

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    #adres dla RAM wej -> przedzial jest 14bitowy parzysty(co 2) 0,2,4,6,.....
    
    adres = 0x00AA          #(0x0000 - 0x3FFF)

    #N = 10

    N = 256   #max to 256 jest
    zapisane_dane = [random.randint(0, 0xFFFF) for _ in range(N)]
    # print(data_to_burst)
    await axi.write(adres, zapisane_dane, size = 2)

    # ===
    results = []
    
    data = await axi.read(adres,length=N, size = 2)
    # data = int(data[0], 2)
    # print(data)
    assert data == zapisane_dane, f"Odczytana próbka {data} != oczekiwana {zapisane_dane}"

    pass
@cocotb.test()
async def axi_test_5(dut):
    # TEST 5
    # testy odczytu z RAM wyj probki wynikowe pojedyncza 

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    # zapisane_dane = [0xABCD]
    dane_testowe = [random.randint(0, 0xFFFF) for _ in range(8192)]
    #Zapis do RAM wyj
    for i in range(8192):
        dut.RAM_wyj.pamiec_RAM[i].value = dane_testowe[i] # xABCD

    #adres dla RAM wyj -> przedzial jest 15bitowy parzysty(co 2) 0,2,4,6,.....
    # 15 bitowy -> adres[14] decyduje o ktory RAM chodzi
    #0x0000 - 0x3FFF ->RAM wej. 0x4000 - ox7FFF
    i = 102
    i_h = int(i/2)
    adres = 0x4000  + i       #(0x0000 - 0x3FFF)
    
    data = await axi.read(adres,length=1, size = 2)
    data = int(data[0])
    assert data == dane_testowe[i_h], f"Odczytana próbka {data} != oczekiwana {dane_testowe[i_h]}"

    pass
@cocotb.test()
async def axi_test_6(dut):
    # TEST 6
    # testy calego axi. zapis probki spr tej probki i odczyt wyniku

    cocotb.start_soon(Clock(dut.a_clk, 10, units="ns").start())

    dut.a_rst_n.value = 0
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    dut.a_rst_n.value = 1

    axi = AXI4Master(dut, "a", dut.a_clk)

    N = 200

    dane_testowe = [random.randint(0, 0xFFFF) for _ in range(N)]
    #Zapis do RAM wyj wynikowe probki
    for i in range(N):
        dut.RAM_wyj.pamiec_RAM[i].value = dane_testowe[i] # xABCD

    adres = 0x0000

    #zapis probke
    zapisane_dane = [random.randint(0, 0xFFFF) for _ in range(N)]
    # print(data_to_burst)
    await axi.write(adres, zapisane_dane, size = 2)

    #odczyt tych probek
    data = await axi.read(adres,length=N, size = 2)

    assert data == zapisane_dane, f"Odczytana próbka {data} != oczekiwana {zapisane_dane}"

    #odczyt probek wyn
    adres = 0x4000

    data = await axi.read(adres,length=N, size = 2)

    assert data == dane_testowe, f"Odczytana próbka {data} != oczekiwana {dane_testowe}"
    pass


######################################################################################################################
