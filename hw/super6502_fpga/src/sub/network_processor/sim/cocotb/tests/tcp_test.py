import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiLiteRam
from cocotbext.eth import MiiPhy, GmiiFrame
import struct

from scapy.layers.inet import * 
from scapy.layers.l2 import *
import logging

from decimal import Decimal

CLK_PERIOD_NS = 10

MII_CLK_PERIOD_NS = 40

class TB:
    def __init__(self, dut):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())
        cocotb.start_soon(Clock(dut.mii_rx_clk, MII_CLK_PERIOD_NS, units="ns").start())
        cocotb.start_soon(Clock(dut.mii_tx_clk, MII_CLK_PERIOD_NS, units="ns").start())


        self.axil_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_regs_axil"), dut.clk, dut.rst)
        self.axil_ram = AxiLiteRam(AxiLiteBus.from_prefix(dut, "m_dma_axil"), dut.clk, dut.rst, size=2**16)

        self.mii_phy = MiiPhy(dut.mii_txd, dut.mii_tx_er, dut.mii_tx_en, dut.mii_tx_clk,
            dut.mii_rxd, dut.mii_rx_er, dut.mii_rx_dv, dut.mii_rx_clk, None, speed=100e6)


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

def ip_to_hex(ip: str) -> int:
    octets = [int(i) for i in ip.split(".")]

    result = int.from_bytes(struct.pack("BBBB", octets[0], octets[1], octets[2], octets[3]))

    return result

@cocotb.test()
async def test_simple(dut):
    tb = TB(dut)

    await tb.cycle_reset()

    src_ip = "172.0.0.2"
    dst_ip = "172.0.0.1"

    local_mac = "02:00:00:11:22:33"

    await tb.axil_master.write_dword(0x0, 0x3)

    await tb.axil_master.write_dword(0x200, 0x1234)
    await tb.axil_master.write_dword(0x204, ip_to_hex(src_ip))
    await tb.axil_master.write_dword(0x208, 0x5678)
    await tb.axil_master.write_dword(0x20c, ip_to_hex(dst_ip))
    await tb.axil_master.write_dword(0x210, 0x3)

    resp = await tb.mii_phy.tx.recv() # type: GmiiFrame

    packet = Ether(resp.get_payload())

    tb.log.info(f"Packet Type: {packet.type:x}")

    assert packet.type == 0x806, "Packet type is not ARP!"

    
    arp_request = packet.payload
    assert isinstance(arp_request, ARP)

    tb.log.info(f"Arp OP: {arp_request.op}")
    tb.log.info(f"Arp hwsrc: {arp_request.hwsrc}")
    tb.log.info(f"Arp hwdst: {arp_request.hwdst}")
    tb.log.info(f"Arp psrc: {arp_request.psrc}")
    tb.log.info(f"Arp pdst: {arp_request.pdst}")

    assert arp_request.op == 1, "ARP type is not request!"
    assert arp_request.hwsrc == "02:00:00:aa:bb:cc", "ARP hwsrc does not match expected"
    assert arp_request.hwdst == "00:00:00:00:00:00", "ARP hwdst does not match expected"
    assert arp_request.psrc == src_ip, "ARP psrc does not match expected"
    assert arp_request.pdst == dst_ip, "ARP pdst does not match expected"

    arp_response = Ether(dst=arp_request.hwsrc, src=local_mac)
    arp_response /= ARP(hwsrc=local_mac, hwdst=arp_request.hwsrc, psrc=dst_ip, pdst=arp_request.psrc)
    arp_response = arp_response.build()

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(arp_response))

    await Timer(Decimal(CLK_PERIOD_NS * 1000), units='ns')