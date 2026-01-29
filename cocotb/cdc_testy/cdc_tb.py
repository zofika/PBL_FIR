
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random


@cocotb.test()
async def test_cdc_write(dut):
    """Test zapisu danych przez CDC"""
    
    # Zegarki
    cocotb.start_soon(Clock(dut.clk_a, 10, units="ns").start())  # 100 MHz
    cocotb.start_soon(Clock(dut.clk_b, 7, units="ns").start())   # ~143 MHz
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk_a)
    await RisingEdge(dut.clk_a)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk_a)
    
    # Dane testowe
    test_addr = 5
    test_data = 0xABCD
    
    # Wyślij zapis
    await RisingEdge(dut.clk_a)
    dut.p_address.value = test_addr
    dut.p_data.value = test_data
    dut.p_wr.value = 1
    
    await RisingEdge(dut.clk_a)
    dut.p_wr.value = 0
    
    # Czekaj na synchronizację do domeny B
    for _ in range(10):
        await RisingEdge(dut.clk_b)
    
    # Sprawdź czy CDC_A, CDC_data są ustawione
    assert dut.CDC_A.value.integer == test_addr, \
        f"CDC_A mismatch: expected {test_addr}, got {dut.CDC_A.value.integer}"
    assert dut.CDC_data.value.integer == test_data, \
        f"CDC_data mismatch: expected {test_data:#x}, got {dut.CDC_data.value.integer:#x}"
    
    dut._log.info(f"✓ ZAPIS: addr={test_addr}, data=0x{test_data:04x}")


@cocotb.test()
async def test_cdc_read(dut):
    """Test odczytu danych przez CDC"""
    
    # Zegarki
    cocotb.start_soon(Clock(dut.clk_a, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.clk_b, 7, units="ns").start())
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk_a)
    await RisingEdge(dut.clk_a)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk_a)
    
    # Ustaw dane zwrotne w domenie B
    test_read_data = 0x1234
    dut.data_back.value = test_read_data
    
    # Czekaj na synchronizację (2 flopy w domenie A)
    for _ in range(10):
        await RisingEdge(dut.clk_a)
    
    # Sprawdź p_data_back
    assert dut.p_data_back.value.integer == test_read_data, \
        f"p_data_back mismatch: expected 0x{test_read_data:04x}, got 0x{dut.p_data_back.value.integer:04x}"
    
    dut._log.info(f"✓ ODCZYT: data_back=0x{test_read_data:04x}")


@cocotb.test()
async def test_cdc_write_read_sequence(dut):
    """Test sekwencji zapis -> odczyt"""
    
    # Zegarki
    cocotb.start_soon(Clock(dut.clk_a, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.clk_b, 7, units="ns").start())
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk_a)
    await RisingEdge(dut.clk_a)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk_a)
    
    test_cases = [
        (1, 0x1111),
        (5, 0xABCD),
        (10, 0x1234),
        (32, 0xDEAD),
        (63, 0xBEEF),
    ]
    
    # Zapis wszystkich wartości
    dut._log.info("=== TEST ZAPISU ===")
    for addr, data in test_cases:
        await RisingEdge(dut.clk_a)
        dut.p_address.value = addr
        dut.p_data.value = data
        dut.p_wr.value = 1
        
        await RisingEdge(dut.clk_a)
        dut.p_wr.value = 0
        
        # Czekaj na synchronizację
        for _ in range(10):
            await RisingEdge(dut.clk_b)
        
        dut._log.info(f"✓ ZAPIS: addr={addr}, data=0x{data:04x}")
    
    await Timer(1000, "ns")
    
    # Odczyt wszystkich wartości
    dut._log.info("=== TEST ODCZYTU ===")
    memory = {}
    
    for addr, expected_data in test_cases:
        # Ustaw dane w domenie B dla tego adresu
        dut.data_back.value = expected_data
        memory[addr] = expected_data
        
        # Ustawić adres w domenie A
        await RisingEdge(dut.clk_a)
        dut.p_address.value = addr
        dut.p_wr.value = 0
        
        # Czekaj na synchronizację CDC
        for _ in range(15):
            await RisingEdge(dut.clk_a)
        
        # Sprawdź odczytane dane
        read_data = dut.p_data_back.value.integer
        assert read_data == expected_data, \
            f"ODCZYT MISMATCH: addr={addr}, expected=0x{expected_data:04x}, got=0x{read_data:04x}"
        
        dut._log.info(f"✓ ODCZYT: addr={addr}, data=0x{read_data:04x}")


@cocotb.test()
async def test_cdc_random_write_read(dut):
    """Test losowych zapisów i odczytów"""
    
    # Zegarki
    cocotb.start_soon(Clock(dut.clk_a, 10, units="ns").start())
    cocotb.start_soon(Clock(dut.clk_b, 7, units="ns").start())
    
    # Reset
    dut.rst_n.value = 0
    await RisingEdge(dut.clk_a)
    await RisingEdge(dut.clk_a)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk_a)
    
    dut._log.info("=== TEST LOSOWYCH ZAPISÓW I ODCZYTÓW ===")
    memory = {}
    
    # Wykonaj 10 losowych operacji
    for i in range(10):
        random_addr = random.randint(0, 63)
        random_data = random.randint(0, 0xFFFF)
        
        # ZAPIS
        await RisingEdge(dut.clk_a)
        dut.p_address.value = random_addr
        dut.p_data.value = random_data
        dut.p_wr.value = 1
        memory[random_addr] = random_data
        
        await RisingEdge(dut.clk_a)
        dut.p_wr.value = 0
        
        # Czekaj na synchronizację
        for _ in range(10):
            await RisingEdge(dut.clk_b)
        
        dut._log.info(f"✓ ZAPIS #{i+1}: addr={random_addr}, data=0x{random_data:04x}")
        
        # ODCZYT
        if memory:
            read_addr = random.choice(list(memory.keys()))
            expected_data = memory[read_addr]
            
            await RisingEdge(dut.clk_a)
            dut.p_address.value = read_addr
            dut.p_wr.value = 0
            dut.data_back.value = expected_data
            
            # Czekaj na synchronizację
            for _ in range(15):
                await RisingEdge(dut.clk_a)
            
            read_data = dut.p_data_back.value.integer
            assert read_data == expected_data, \
                f"ODCZYT FAIL: addr={read_addr}, expected=0x{expected_data:04x}, got=0x{read_data:04x}"
            
            dut._log.info(f"✓ ODCZYT #{i+1}: addr={read_addr}, data=0x{read_data:04x}")
        
        await Timer(50, "ns")
    
    dut._log.info("=== ALL RANDOM TESTS PASSED ===")
