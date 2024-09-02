import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiLiteRam, AxiStreamBus, AxiStreamSink

import logging

from decimal import Decimal

CLK_PERIOD_NS = 10

class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())

        self.axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_regs_axil"), dut.clk, dut.rst)
        self.axil_ram = AxiLiteRam(AxiLiteBus.from_prefix(dut, "m_dma_axil"), dut.clk, dut.rst, size=2**16)

    async def cycle_reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)  # type: ignore
        await RisingEdge(self.dut.clk)  # type: ignore
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)  # type: ignore
        await RisingEdge(self.dut.clk)  # type: ignore
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)  # type: ignore
        await RisingEdge(self.dut.clk)  # type: ignore

@cocotb.test()
async def test_simple(dut):
    tb = TB(dut)

    await tb.cycle_reset()

    test_data = bytearray([x % 256 for x in range(256)])

    tb.axil_ram.write(0x1000, test_data)
    tb.axil_ram.write(0x2000, test_data)

    tb.axil_ram.write_dword(0x00000400, 0x00001000)
    tb.axil_ram.write_dword(0x00000404, 64)
    tb.axil_ram.write_dword(0x00000408, 0)
    tb.axil_ram.write_dword(0x0000040c, 0x000000400)

    await tb.axil_master.write_dword(0x22c, 0x000)
    await tb.axil_master.write_dword(0x220, 0x400)
    await tb.axil_master.write_dword(0x224, 0x400)

    await Timer(Decimal(CLK_PERIOD_NS * 400), units='ns')