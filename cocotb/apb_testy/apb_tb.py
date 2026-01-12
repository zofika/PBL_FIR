import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from apb_master import APBMaster


@cocotb.test()
async def apb_basic_rw_test(dut):
    # Clock 100 MHz
    cocotb.start_soon(Clock(dut.PCLK, 10, units="ns").start())

    apb = APBMaster(dut)

    # Reset
    dut.PRESETn.value = 0
    dut.PSELx.value   = 0
    dut.PENABLE.value = 0
    dut.PWRITE.value  = 0
    dut.PADDR.value   = 0
    dut.PWDATA.value  = 0

    for _ in range(5):
        await RisingEdge(dut.PCLK)

    dut.PRESETn.value = 1
    await RisingEdge(dut.PCLK)

    # -----------------------------
    # WRITE
    # -----------------------------
    await apb.write(0x00, 0xABCD)

    # sprawdź impuls p_wr
    assert dut.p_wr.value == 0

    # -----------------------------
    # READ
    # -----------------------------
    # Symulujemy peryferium
    dut.p_data_back.value = 0xABCD

    data = await apb.read(0x00)
    assert (data & 0xFFFF) == 0xABCD

    # -----------------------------
    # Back-to-back write
    # -----------------------------
    await apb.write(0x04, 0x1234)
    await apb.write(0x08, 0x5678)

    dut._log.info("APB test PASSED ✅")
