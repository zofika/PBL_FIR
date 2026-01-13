from cocotb.triggers import RisingEdge

from cocotb.triggers import Timer

async def wait_for_pready(dut):
        while True:
            await RisingEdge(dut.PCLK)
            if dut.PREADY.value == 1:
                break
            dut._log.debug("Waiting for PREADY...")

class APBMaster:
    def __init__(self, dut):
        self.dut = dut

    async def write(self, addr, data):
        dut = self.dut

        # SETUP
        dut.PADDR.value   = addr
        dut.PWDATA.value  = data
        dut.PWRITE.value  = 1
        dut.PSELx.value   = 1
        dut.PENABLE.value = 0
        await RisingEdge(dut.PCLK)

        # ACCESS
        dut.PENABLE.value = 1

        # Wait for PREADY
        await wait_for_pready(dut)

        # IDLE
        dut.PSELx.value   = 0
        dut.PENABLE.value = 0
        dut.PWRITE.value  = 0

    async def read(self, addr):
        dut = self.dut

        # SETUP
        dut.PADDR.value   = addr
        dut.PWRITE.value  = 0
        dut.PSELx.value   = 1
        dut.PENABLE.value = 0
        await RisingEdge(dut.PCLK)

        # ACCESS
        dut.PENABLE.value = 1

        # Wait for PREADY
        await wait_for_pready(dut)
        
        # IDLE
        dut.PSELx.value   = 0
        dut.PENABLE.value = 0

        await Timer(1, "ns") #czekaj na ustabilizowanie się PRDATA
        data = int(dut.PRDATA.value)

        return data
