import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ReadOnly
from cocotbext.apb import ApbMaster, ApbBus

from cocotb.regression import TestFactory
import random

class APB_SoC_Tester:
    def __init__(self, dut):
        self.dut = dut
        self.bus = ApbBus(dut, "")
        self.apb = ApbMaster(self.bus, dut.PCLK)
        self.expected_ram = {}

    async def setup(self,speed_ratio=2):
        """
        Konfiguracja zegarów: Domena B jest szybsza. (domena A, czyli PCLK to APB) 
        speed_ratio: o ile clk_b jest szybszy od PCLK
        """
        period_a_ps = 20000 
        # 1. Obliczamy okres
        raw_period_b = period_a_ps / speed_ratio
        # 2. Wymuszamy, aby okres był liczbą całkowitą i PARZYSTĄ
        #    (dzielimy przez 2, zaokrąglamy, mnożymy przez 2)
        period_b_ps = int(raw_period_b // 2) * 2
        
        if period_b_ps == 0: period_b_ps = 2 # Zabezpieczenie przed ekstremami
        self.dut._log.info(f"Ustawiam zegary: PCLK={period_a_ps}ps, clk_b={period_b_ps}ps (ratio: {speed_ratio})")

        cocotb.start_soon(Clock(self.dut.PCLK,  period_a_ps, units="ps").start())
        cocotb.start_soon(Clock(self.dut.clk_b, period_b_ps, units="ps").start())

        # Inicjalizacja sygnałów sterujących (wejścia "FSM")
        self.dut.FSM_MUX_CDC.value = 0  # 0: APB ma kontrolę nad adresem RAM
        self.dut.pracuje.value = 0     # 0: Pozwalamy na zapis (bramka AND)
        self.dut.DONE.value = 0
        self.dut.address_FIR.value = 0
        
        # Reset asynchroniczny i APB
        self.dut.PRESETn.value = 0
        self.dut.rst_n.value = 0
        await Timer(period_a_ps * 5, units="ns")
        self.dut.PRESETn.value = 1
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.PCLK)
        self.dut._log.info(f"Zegary ustawione: PCLK={period_a_ps/1000}ns, clk_b={period_b_ps/1000}ns")

    async def write_ram_random(self, num_tests=20):
        """Losowy zapis do RAM i weryfikacja"""
        for i in range(num_tests):
            addr = random.randint(0, 31) # adresy RAM od 0 do 31
            data = random.randint(0, 0xFFFF)
            
            self.dut._log.info(f"Test {i}: Zapis RAM[{addr}] = {data:#x}")
            await self.apb.write(addr, data)
            self.expected_ram[addr] = data
            
            # Ponieważ domena B jest szybsza, dane powinny być w RAM 
            # niemal natychmiast po zakończeniu transakcji APB
            #await RisingEdge(self.dut.clk_b)
            #await ReadOnly()
            
            # Weryfikacja sygnału wyjściowego z RAM (jeśli adres się zgadza)
            # if self.dut.wsp_address_in.value.integer == addr:
            #     actual = self.dut.wsp_data.value.integer
            #     assert actual == data, f"Błąd zapisu! Adr: {addr}, Jest: {actual:#x}, Ma być: {data:#x}"

    async def read_ram_and_verify(self):
        """Odczytuje wszystkie zapisane wcześniej adresy przez APB i weryfikuje ich zawartość"""
        self.dut._log.info("\n--- Rozpoczynam odczyt weryfikacyjny RAM przez APB ---")
        
        self.dut.FSM_MUX_CDC.value = 0 #ustawiamy mux (bo nie ma FSM)

        for addr, expected_val in self.expected_ram.items():
            read_data_raw = await self.apb.read(addr) #odczyt
            
            # Konwersja z LogicArray/bytes na int (zależnie od wersji cocotbext-apb)
            if isinstance(read_data_raw, int):
                read_val = read_data_raw
            else:
                read_val = int.from_bytes(read_data_raw, byteorder="little")
            read_val &= 0xFFFF # Maskujemy do 16 bitów (szerokość Twojej pamięci)
            
            self.dut._log.info(f"Odczyt RAM[{addr:#x}] = {read_val:#x} (Oczekiwano: {expected_val:#x})")
            assert read_val == expected_val, \
                f"Błąd odczytu! Adres: {addr:#x}, Odczytano: {read_val:#x}, Oczekiwano: {expected_val:#x}"

@cocotb.test()
async def simple_write_read_test(dut):
    # Inicjalizacja testera (ratio np. 2.0 dla stabilności)
    tester = APB_SoC_Tester(dut)
    await tester.setup(speed_ratio=2.0)

    address0 = 0x8
    value0 = 0xABCD
    address = 0x9
    value = 0xDEAD

    dut._log.info(f"KROK 1: Zapis wartości {value:#x} pod adres {address:#x}")
    
    # 1. Wykonanie zapisu przez APB
    # Upewniamy się, że MUX pozwala APB na dostęp do RAM
    dut.FSM_MUX_CDC.value = 0
    await tester.apb.write(address0, value0)
    await tester.apb.write(address, value)
   
    await ReadOnly() # Synchronizacja z symulatorem dla stabilnego odczytu sygnałów

    read_result = await tester.apb.read(address0)
    
    # Konwersja wyniku (obsługa różnych wersji biblioteki cocotbext-apb)
    if isinstance(read_result, int):
        read_val = read_result
    else:
        read_val = int.from_bytes(read_result, byteorder="little")
        
    read_val &= 0xFFFF # Maskowanie do 16 bitów
    
    assert read_val == value0, \
        f"Błąd odczytu APB! Otrzymano {read_val:#x}, oczekiwano {value0:#x}"

@cocotb.test()
async def write_read_random_ram_and_ratio_test(dut,ratio=2.0):
    """Główna logika testu, która przyjmuje ratio jako parametr"""
    tester = APB_SoC_Tester(dut)
    
    dut._log.info(f"\n--- URUCHAMIANIE TESTU: RATIO = {ratio} ---")
    
    await tester.setup(speed_ratio=ratio)
    
    await tester.write_ram_random(10) #zapisz 10 losowych wartości
    await tester.read_ram_and_verify()

# --- Mechanizm TestFactory ---
# Tworzy osobne testy w raporcie (np. run_ratio_test_001, _002 itd.)
factory = TestFactory(test_function=write_read_random_ram_and_ratio_test)
factory.add_option("ratio", [3.0, 4.0, 6.0])  # Różne ratio zegarów do przetestowania
factory.generate_tests()

@cocotb.test()
async def test_control_registers_readback(dut):
    tester = APB_SoC_Tester(dut)
    # Ustawiamy szybszy clk_b dla sprawnego działania CDC
    await tester.setup(speed_ratio=3.0)

    # Definicja adresów na podstawie dekodera (CDC_A[5]=1 -> 0x20 + nr_rejestru)
    REG_START      = 0x20 # nr_Rejestru 0
    REG_DONE       = 0x21 # nr_Rejestru 1
    REG_PRACUJE    = 0x22 # nr_Rejestru 2
    REG_ILE_WSP    = 0x23 # nr_Rejestru 3
    REG_ILE_PROBEK = 0x24 # nr_Rejestru 4

    ilosc_wsp = 15
    ilosc_probek = 100

    await tester.apb.write(REG_ILE_WSP, ilosc_wsp)
    await tester.apb.write(REG_ILE_PROBEK,ilosc_probek)

    raw_wsp = await tester.apb.read(REG_ILE_WSP)  
    val_wsp = int.from_bytes(raw_wsp, byteorder='little') & 0xFFFF  # Bezpieczna konwersja bajtów na int
    assert val_wsp == ilosc_wsp, f"Blad! Oczekiwano {ilosc_wsp}, otrzymano {val_wsp}"
        
    raw_probek = await tester.apb.read(REG_ILE_PROBEK)
    val_probek = int.from_bytes(raw_probek, byteorder='little') & 0xFFFF
    assert val_probek == ilosc_probek, f"Blad! Oczekiwano {ilosc_probek}, otrzymano {val_probek}"

    #Rejestr START (0x20) w Twoim RTL sam się zeruje: if(rej[0][0]) rej[0][0] <= 1'b0;
    await tester.apb.write(REG_START, 0x0001)
    await Timer(100, units="ns") # Czekamy aż logika clk_b go wyzeruje
    raw_start = await tester.apb.read(REG_START)
    val_start = int.from_bytes(raw_start, byteorder='little') & 0xFFFF
    assert val_start == 0, "Błąd! Rejestr START nie wyzerował się automatycznie"

    #REG_DONE
    try:
        await tester.apb.write(REG_DONE, 0x1234,error_expected=1)
        dut._log.warning(f"Zapis do {hex(REG_DONE)} zakończony, sprawdzam czy dane NIE zostały zapisane")
    except Exception as e:
        # Jeśli cocotbext-apb wykryło PSLVERR, rzuci wyjątek
        dut._log.info(f"Wykryto oczekiwany błąd transakcji APB na adresie {hex(REG_DONE)}: {e}")

        # Weryfikacja: Odczytujemy i sprawdzamy czy wartość to nadal 0
        raw_val = await tester.apb.read(REG_DONE)
        val = int.from_bytes(raw_val, byteorder='little') & 0xFFFF
        assert val == 0, f"Błąd! Rejestr RO pod adresem {hex(REG_DONE)} przyjął wartość!"

    #REG_PRACUJE
    try:
        await tester.apb.write(REG_PRACUJE, 0x1234,error_expected=1)
        dut._log.info(f"Zapis do {hex(REG_PRACUJE)} zakończony, sprawdzam czy dane NIE zostały zapisane")
    except Exception as e:
        # Jeśli cocotbext-apb wykryło PSLVERR, rzuci wyjątek
        dut._log.info(f"Wykryto oczekiwany błąd transakcji APB na adresie {hex(REG_PRACUJE)}: {e}")

        # Weryfikacja: Odczytujemy i sprawdzamy czy wartość to nadal 0
        raw_val = await tester.apb.read(REG_PRACUJE)
        val = int.from_bytes(raw_val, byteorder='little') & 0xFFFF
        assert val == 0, f"Błąd! Rejestr RO pod adresem {hex(REG_PRACUJE)} przyjął wartość!" # Zakładamy, że wejścia DONE i Pracuje są w stanie 0
