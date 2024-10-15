import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiLiteRam
from cocotbext.eth import MiiPhy, GmiiFrame
import struct

from scapy.layers.inet import Ether, IP, TCP
from scapy.layers.l2 import ARP
from scapy.utils import PcapWriter

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
    pktdump = PcapWriter("tcp.pcapng", append=False, sync=True)


    tb = TB(dut)

    await tb.cycle_reset()

    dut_ip = "172.0.0.2"
    tb_ip = "172.0.0.1"

    dut_port = 0x1234
    tb_port = 0x5678

    tb_mac = "02:00:00:11:22:33"

    await tb.axil_master.write_dword(0x0, 0x1807)

    await tb.axil_master.write_dword(0x200, dut_port)
    await tb.axil_master.write_dword(0x204, ip_to_hex(dut_ip))
    await tb.axil_master.write_dword(0x208, tb_port)
    await tb.axil_master.write_dword(0x20c, ip_to_hex(tb_ip))
    await tb.axil_master.write_dword(0x210, 0x3)

    resp = await tb.mii_phy.tx.recv() # type: GmiiFrame

    packet = Ether(resp.get_payload())
    pktdump.write(packet)

    tb.log.info(f"Packet Type: {packet.type:x}")

    assert packet.type == 0x806, "Packet type is not ARP!"


    arp_request = packet.payload
    assert isinstance(arp_request, ARP)

    tb.log.info(f"Arp OP: {arp_request.op}")
    tb.log.info(f"Arp hwsrc: {arp_request.hwsrc}")
    tb.log.info(f"Arp hwdst: {arp_request.hwdst}")
    tb.log.info(f"Arp psrc: {arp_request.psrc}")
    tb.log.info(f"Arp pdst: {arp_request.pdst}")

    dut_mac = arp_request.hwsrc
    dut_ip = arp_request.psrc

    assert arp_request.op == 1, "ARP type is not request!"
    assert arp_request.hwsrc == "02:00:00:aa:bb:cc", "ARP hwsrc does not match expected"
    assert arp_request.hwdst == "00:00:00:00:00:00", "ARP hwdst does not match expected"
    assert arp_request.psrc == dut_ip, "ARP psrc does not match expected"
    assert arp_request.pdst == tb_ip, "ARP pdst does not match expected"

    arp_response = Ether(dst=dut_mac, src=tb_mac)
    arp_response /= ARP(op="is-at", hwsrc=tb_mac, hwdst=dut_mac, psrc=tb_ip, pdst=dut_ip)
    arp_response = arp_response.build()

    pktdump.write(arp_response)

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(arp_response))

    # 1. DUT sends syn with seq number

    resp = await tb.mii_phy.tx.recv() # type: GmiiFrame
    packet = Ether(resp.get_payload())
    pktdump.write(packet)
    tb.log.info(f"Packet Type: {packet.type:x}")

    ip_packet = packet.payload
    assert isinstance(ip_packet, IP)

    tcp_packet = ip_packet.payload
    assert isinstance(tcp_packet, TCP)

    tb.log.info(f"Source Port: {tcp_packet.sport}")
    tb.log.info(f"Dest Port: {tcp_packet.dport}")
    tb.log.info(f"Seq: {tcp_packet.seq}")
    tb.log.info(f"Ack: {tcp_packet.ack}")
    tb.log.info(f"Data Offs: {tcp_packet.dataofs}")
    tb.log.info(f"flags: {tcp_packet.flags}")
    tb.log.info(f"window: {tcp_packet.window}")
    tb.log.info(f"Checksum: {tcp_packet.chksum}")


    dut_seq = tcp_packet.seq
    tb_seq = 11111111

    # 2. Send SYNACK with seq as our sequence number, and ACK as their sequence number plus 1

    tcp_synack = Ether(dst=dut_mac, src=tb_mac)
    tcp_synack /= IP(src=tb_ip, dst=dut_ip)
    tcp_synack /= TCP(sport=tb_port, dport=dut_port, seq=tb_seq, ack=dut_seq+1, flags="SA")
    tcp_synack = tcp_synack.build()
    pktdump.write(tcp_synack)

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_synack))

    # 3. Receieve ACK with our sequence number plus 1

    resp = await tb.mii_phy.tx.recv() # type: GmiiFrame
    packet = Ether(resp.get_payload())
    pktdump.write(packet)
    tb.log.info(f"Packet Type: {packet.type:x}")


    ip_packet = packet.payload
    assert isinstance(ip_packet, IP)

    tcp_packet = ip_packet.payload
    assert isinstance(tcp_packet, TCP)

    tb.log.info(f"Source Port: {tcp_packet.sport}")
    tb.log.info(f"Dest Port: {tcp_packet.dport}")
    tb.log.info(f"Seq: {tcp_packet.seq}")
    tb.log.info(f"Ack: {tcp_packet.ack}")
    tb.log.info(f"Data Offs: {tcp_packet.dataofs}")
    tb.log.info(f"flags: {tcp_packet.flags}")
    tb.log.info(f"window: {tcp_packet.window}")
    tb.log.info(f"Checksum: {tcp_packet.chksum}")

    assert tcp_packet.ack == tb_seq + 1

    # Try to send a packet from M2S

    # Construct a descriptor in memry
    tb.axil_ram.write_dword(0x00000000, 0x00001000)
    tb.axil_ram.write_dword(0x00000004, 64)
    tb.axil_ram.write_dword(0x00000008, 0)
    tb.axil_ram.write_dword(0x0000000c, 0)

    test_data = bytearray([x % 256 for x in range(256)])

    tb.axil_ram.write(0x1000, test_data)



    await tb.axil_master.write_dword(0x22c, 0)
    await tb.axil_master.write_dword(0x220, 0x00000000)
    await tb.axil_master.write_dword(0x224, 0x00000000)

    resp = await tb.mii_phy.tx.recv() # type: GmiiFrame
    packet = Ether(resp.get_payload())
    pktdump.write(packet)
    tb.log.info(f"Packet Type: {packet.type:x}")

    tcp_packet = ip_packet.payload
    assert isinstance(tcp_packet, TCP)

    tb.log.info(f"Source Port: {tcp_packet.sport}")
    tb.log.info(f"Dest Port: {tcp_packet.dport}")
    tb.log.info(f"Seq: {tcp_packet.seq}")
    tb.log.info(f"Ack: {tcp_packet.ack}")
    tb.log.info(f"Data Offs: {tcp_packet.dataofs}")
    tb.log.info(f"flags: {tcp_packet.flags}")
    tb.log.info(f"window: {tcp_packet.window}")
    tb.log.info(f"Checksum: {tcp_packet.chksum}")

    pktdump.close()