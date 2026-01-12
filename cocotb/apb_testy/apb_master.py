from cocotb.triggers import RisingEdge


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
        await RisingEdge(dut.PCLK)

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
        await RisingEdge(dut.PCLK)

        data = int(dut.PRDATA.value)

        # IDLE
        dut.PSELx.value   = 0
        dut.PENABLE.value = 0

        return data
