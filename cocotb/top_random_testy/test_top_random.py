import os
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


class ApbMasterLite:
    def __init__(self, dut):
        self.dut = dut

    @property
    def clk(self):
        return self.dut.apb_PCLK

    async def idle(self, cycles: int = 1):
        self.dut.apb_PSEL.value = 0
        self.dut.apb_PENABLE.value = 0
        self.dut.apb_PWRITE.value = 0
        self.dut.apb_PADDR.value = 0
        self.dut.apb_PWDATA.value = 0
        for _ in range(cycles):
            await RisingEdge(self.clk)

    async def write(self, addr: int, data: int):
        # APB wrapper in apb.sv triggers write when PSEL && PWRITE && !PENABLE
        self.dut.apb_PADDR.value = addr & 0xFFFFFFFF
        self.dut.apb_PWDATA.value = data & 0xFFFFFFFF
        self.dut.apb_PWRITE.value = 1
        self.dut.apb_PSEL.value = 1
        self.dut.apb_PENABLE.value = 0
        await RisingEdge(self.clk)
        await Timer(1, unit="ps")

        # Deassert to avoid repeating the write on the next edge
        self.dut.apb_PSEL.value = 0
        self.dut.apb_PWRITE.value = 0
        self.dut.apb_PENABLE.value = 0
        await RisingEdge(self.clk)

    async def read(self, addr: int) -> int:
        # SETUP: latch address when PSEL && !PWRITE && !PENABLE
        self.dut.apb_PADDR.value = addr & 0xFFFFFFFF
        self.dut.apb_PWRITE.value = 0
        self.dut.apb_PSEL.value = 1
        self.dut.apb_PENABLE.value = 0
        await RisingEdge(self.clk)

        # ACCESS: raise PENABLE; apb.sv inserts a single wait-state
        self.dut.apb_PENABLE.value = 1

        while True:
            await RisingEdge(self.clk)
            await Timer(1, unit="ps")
            if int(self.dut.apb_PREADY.value) == 1:
                break

        await Timer(1, unit="ps")
        data = int(self.dut.apb_PRDATA.value) & 0xFFFFFFFF

        # IDLE
        self.dut.apb_PSEL.value = 0
        self.dut.apb_PENABLE.value = 0
        await RisingEdge(self.clk)

        return data


def _u16(x: int) -> int:
    return x & 0xFFFF


async def _reset_top(dut):
    # Default safe values for AXI inputs (we don't use AXI in this test)
    dut.a_awaddr.value = 0
    dut.a_awvalid.value = 0
    dut.a_awlen.value = 0
    dut.a_awsize.value = 2
    dut.a_awburst.value = 1

    dut.a_wvalid.value = 0
    dut.a_wlast.value = 0
    dut.a_wdata.value = 0
    dut.a_wstrb.value = 0

    dut.a_bready.value = 1

    dut.a_arvalid.value = 0
    dut.a_araddr.value = 0
    dut.a_arsize.value = 2
    dut.a_arburst.value = 1
    dut.a_arlen.value = 0

    dut.a_rready.value = 1

    # APB defaults
    dut.apb_PADDR.value = 0
    dut.apb_PSEL.value = 0
    dut.apb_PENABLE.value = 0
    dut.apb_PWRITE.value = 0
    dut.apb_PWDATA.value = 0

    # Resets asserted
    dut.a_rst_n.value = 0
    dut.apb_PRESETn.value = 0

    # Let both clocks run a bit
    for _ in range(5):
        await RisingEdge(dut.a_clk)
    for _ in range(5):
        await RisingEdge(dut.apb_PCLK)

    # Release
    dut.a_rst_n.value = 1
    for _ in range(2):
        await RisingEdge(dut.a_clk)

    dut.apb_PRESETn.value = 1
    for _ in range(2):
        await RisingEdge(dut.apb_PCLK)


async def _coeff_read_check(apb: ApbMasterLite, dut, addr: int, expected_u16: int, retries: int = 6):
    for _ in range(retries):
        raw = await apb.read(addr)
        got = raw & 0xFFFF
        if got == expected_u16:
            return
        # CDC/RAM path may need extra cycles to settle
        for _ in range(2):
            await RisingEdge(dut.a_clk)
    assert False, f"Coeff read mismatch at addr {addr}: got 0x{got:04x} expected 0x{expected_u16:04x}"


async def _top_coeff_ram_random_round(apb: ApbMasterLite, dut, n_ops: int, seed: int):
    """One randomized round: init full coeff RAM, then random R/W, then full readback."""
    random.seed(seed)

    depth = 32
    model = [0] * depth

    # Initialize coefficients with random values
    for addr in range(depth):
        value = random.getrandbits(16)
        model[addr] = value
        await apb.write(addr, value)
        for _ in range(2):
            await RisingEdge(dut.a_clk)

    # Random read/write operations
    for _ in range(n_ops):
        addr = random.randrange(depth)
        if random.random() < 0.55:
            value = random.getrandbits(16)
            model[addr] = value
            await apb.write(addr, value)
            for _ in range(2):
                await RisingEdge(dut.a_clk)
        else:
            await _coeff_read_check(apb, dut, addr, _u16(model[addr]))

    # Final full sweep readback
    for addr in range(depth):
        await _coeff_read_check(apb, dut, addr, _u16(model[addr]))


async def _top_coeff_ram_random(dut, a_clk_ns: int, apb_clk_ns: int, n_ops: int = 200, seed: int | None = None):
    if seed is None:
        seed_env = os.getenv("SEED")
        seed = int(seed_env, 0) if seed_env is not None else random.randrange(0, 2**32)

    n_ops_env = os.getenv("N_OPS")
    if n_ops_env is not None:
        n_ops = int(n_ops_env, 0)

    n_seeds = int(os.getenv("N_SEEDS", "1"), 0)
    if n_seeds < 1:
        n_seeds = 1

    dut._log.info(
        f"TOP coeff RAM random: a_clk={a_clk_ns}ns apb_clk={apb_clk_ns}ns n_ops={n_ops} "
        f"n_seeds={n_seeds} base_seed={seed}"
    )

    clk_a_task = cocotb.start_soon(Clock(dut.a_clk, a_clk_ns, unit="ns").start())
    clk_apb_task = cocotb.start_soon(Clock(dut.apb_PCLK, apb_clk_ns, unit="ns").start())

    try:
        await _reset_top(dut)

        apb = ApbMasterLite(dut)
        await apb.idle(2)

        for i in range(n_seeds):
            round_seed = (seed + i) & 0xFFFFFFFF
            dut._log.info(f"  round {i + 1}/{n_seeds}: seed={round_seed}")
            await _top_coeff_ram_random_round(apb, dut, n_ops=n_ops, seed=round_seed)
            await apb.idle(2)
    finally:
        # Avoid multiple clocks driving the same signal across regression tests.
        clk_a_task.cancel()
        clk_apb_task.cancel()


@cocotb.test()
async def top_coeff_ram_rand_a10_apb20(dut):
    await _top_coeff_ram_random(dut, a_clk_ns=10, apb_clk_ns=20, n_ops=200)


@cocotb.test()
async def top_coeff_ram_rand_a8_apb16(dut):
    await _top_coeff_ram_random(dut, a_clk_ns=8, apb_clk_ns=16, n_ops=200)


@cocotb.test()
async def top_coeff_ram_rand_a10_apb30(dut):
    await _top_coeff_ram_random(dut, a_clk_ns=10, apb_clk_ns=30, n_ops=200)


@cocotb.test()
async def top_coeff_ram_rand_a12_apb24(dut):
    await _top_coeff_ram_random(dut, a_clk_ns=12, apb_clk_ns=24, n_ops=200)
