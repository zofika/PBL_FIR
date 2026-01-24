import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
#from apb_master import APBMaster #wlasny moduł

from cocotbext.apb import ApbMaster, ApbBus

import random
from cocotb.triggers import Timer
from cocotb.types import LogicArray

@cocotb.test()
async def apb_basic_write_test(dut):

    cocotb.start_soon(Clock(dut.PCLK, 10, units="ns").start())

    # APB bus + master - use wrapper to map signals
    bus = ApbBus(dut, "")
    apb = ApbMaster(bus, dut.PCLK)

    # Reset
    dut.PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.PCLK)
    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)

    # Generate random address and value
    random_adr   = random.randint(0, 63)
    random_value = random.randint(0x0000, 0xFFFF)

    # START WRITE (nie await!)
    write_task = cocotb.start_soon(apb.write(random_adr, random_value))
    
    # czekamy aż adres zostanie ustawiony
    MAX_CYCLES = 10
    found = False

    for _ in range(MAX_CYCLES):
        await RisingEdge(dut.PCLK)
        if dut.p_address.value.integer == random_adr:
            found = True
            break

    assert found, f"Timeout: p_address {random_adr:#x} not seen within {MAX_CYCLES} cycles"

    # N – sprawdzamy czy p_address, p_data i p_wr są poprawne
    #assert dut.p_address.value.integer == random_adr
    assert dut.p_wr.value.integer == 1, "p_wr not asserted in cycle after p_address"
    assert dut.p_data.value.integer == random_value, \
        f"p_data mismatch: expected {random_value:#x}, got {dut.p_data.value.integer:#x}"
    
    # N+1 – sprawdzamy czy p_wr się wyzerowało
    await RisingEdge(dut.PCLK)
    assert dut.p_wr.value.integer == 0, "p_wr not deasserted one cycle after write"

@cocotb.test()
async def apb_basic_read_test(dut):

    cocotb.start_soon(Clock(dut.PCLK, 10, units="ns").start())

    # APB bus + master - use wrapper to map signals
    bus = ApbBus(dut,"")
    apb = ApbMaster(bus, dut.PCLK)

    # Reset
    dut.PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.PCLK)
    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)
    # -----------------------------
    random_value = random.randint(0x0000, 0xFFFF)
    dut.p_data_back.value = random_value

    # Odczyt
    data = await apb.read(0x00) # adres dowolny bo i tak ręcznie wpisujemy wartość do p_data_back

    # CHECK READ DATA
    data_int = int.from_bytes(data, byteorder="little")
    assert (data_int & 0xFFFF) == random_value
    await RisingEdge(dut.PCLK)

@cocotb.test()
async def apb_write_10x_test(dut):

    cocotb.start_soon(Clock(dut.PCLK, 10, units="ns").start())

    bus = ApbBus(dut, "")
    apb = ApbMaster(bus, dut.PCLK)

    # Reset
    dut.PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.PCLK)
    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)

    for i in range(10):
        random_adr   = random.randint(0, 63)
        random_value = random.randint(0x0000, 0xFFFF)

        dut._log.info(f"WRITE #{i}: addr={random_adr:#x}, data={random_value:#x}")

        write_task = cocotb.start_soon(apb.write(random_adr, random_value))

        # czekamy aż adres się pojawi
        MAX_CYCLES = 10
        found = False

        for _ in range(MAX_CYCLES):
            await RisingEdge(dut.PCLK)
            if dut.p_address.value.integer == random_adr:
                found = True
                break

        assert found, f"[WRITE #{i}] Timeout waiting for p_address"

        # cykl handshake
        assert dut.p_wr.value.integer == 1, f"[WRITE #{i}] p_wr not asserted"
        assert dut.p_data.value.integer == random_value, \
            f"[WRITE #{i}] p_data mismatch"

        # następny cykl: p_wr musi spaść
        await RisingEdge(dut.PCLK)
        assert dut.p_wr.value.integer == 0, f"[WRITE #{i}] p_wr not deasserted"

        await write_task

@cocotb.test()
async def apb_read_10x_test(dut):

    cocotb.start_soon(Clock(dut.PCLK, 10, units="ns").start())

    bus = ApbBus(dut, "")
    apb = ApbMaster(bus, dut.PCLK)

    # Reset
    dut.PRESETn.value = 0
    for _ in range(5):
        await RisingEdge(dut.PCLK)
    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)

    for i in range(10):
        random_value = random.randint(0x0000, 0xFFFF)
        dut.p_data_back.value = random_value

        dut._log.info(f"READ #{i}: expected data={random_value:#x}")

        data = await apb.read(0x00)

        data_int = int.from_bytes(data, byteorder="little")

        assert (data_int & 0xFFFF) == random_value, \
            f"[READ #{i}] Read {data_int:#x} != expected {random_value:#x}"
        await RisingEdge(dut.PCLK)
