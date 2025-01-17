from scapy.data import IP_PROTOS

from scapy import sendrecv

from scapy.config import conf

from scapy.supersocket import L3RawSocket

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteBus, AxiLiteMaster, AxiLiteRam
from cocotbext.eth import MiiPhy, GmiiFrame
import struct

from scapy.layers.inet import IP, TCP
from scapy.layers.l2 import ARP, Ether
from scapy.packet import Packet
from scapy.utils import PcapWriter

from scapy.layers.tuntap import TunTapInterface
import logging

from decimal import Decimal

import random

CLK_PERIOD_NS = 10

MII_CLK_PERIOD_NS = 40


import socket

# In order for this to work, you need to run these commands:
# sudo ip tuntap add name tun0 mode tun group netdev
# sudo ip a add 172.0.0.1 peer 172.0.0.2 dev tun0
# sudo ip link set tun0 up


def main():
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind(("172.0.0.1", 5678))
    serversocket.listen(5)

    t = TunTapInterface('tun0')

    tcp_syn = IP(src="172.0.0.2", dst="172.0.0.1")/TCP(sport=1234, dport=5678, seq=0, ack=0, flags="S")
    t.send(tcp_syn)

    pkt = t.recv()
    print(pkt)


if __name__ == "__main__":
    main()



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
async def test_irl(dut):
    tb = TB(dut)

    async def read_tcp_from_dut():
        resp = await tb.mii_phy.tx.recv() # type: GmiiFrame
        packet = Ether(resp.get_payload())
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

        return ip_packet

    #############################
    # Reset DUT                 #
    #############################


    await tb.cycle_reset()

    dut_ip = "172.0.0.2"
    tb_ip = "172.0.0.1"

    tb_mac = "02:00:00:11:22:33"

    dut_port = random.randint(1024, 65535)
    tb_port = random.randint(1024, 65535)

    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind((tb_ip, tb_port))
    serversocket.listen(1)
    t = TunTapInterface('tun0')


    ###############################
    # Configure DUT Network block #
    ###############################

    await tb.axil_master.write_dword(0x0, 0x1807)

    await tb.axil_master.write_dword(0x200, dut_port)
    await tb.axil_master.write_dword(0x204, ip_to_hex(dut_ip))
    await tb.axil_master.write_dword(0x208, tb_port)
    await tb.axil_master.write_dword(0x20c, ip_to_hex(tb_ip))
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

    dut_mac = arp_request.hwsrc
    dut_ip = arp_request.psrc

    assert arp_request.op == 1, "ARP type is not request!"
    assert arp_request.hwsrc == "02:00:00:aa:bb:cc", "ARP hwsrc does not match expected"
    assert arp_request.hwdst == "00:00:00:00:00:00", "ARP hwdst does not match expected"
    assert arp_request.psrc == dut_ip, "ARP psrc does not match expected"
    assert arp_request.pdst == tb_ip, "ARP pdst does not match expected"

    # hardcode the ARP response for now
    arp_response = Ether(dst=dut_mac, src=tb_mac)
    arp_response /= ARP(op="is-at", hwsrc=tb_mac, hwdst=dut_mac, psrc=tb_ip, pdst=dut_ip)
    arp_response = arp_response.build()

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(arp_response))


    ###############################
    # Start TCP handshake         #
    ###############################

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)

    while True:
        pkt = t.recv()
        assert isinstance(pkt, Packet)
        if (pkt.proto == IP_PROTOS.tcp):
            break
    print(pkt)

    tcp_synack = Ether(dst=dut_mac, src=tb_mac)  / pkt

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_synack.build()))

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)

    con, addr = serversocket.accept()

    ###############################
    # Send data from DUT to host  #
    ###############################

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

    t.send(packet.payload)

    con.recv(64)
    tb.log.info("Received 64 packets")

    ###############################
    # Close connection from host  #
    ###############################

    con.close()
    serversocket.close()

    while True:
        pkt = t.recv()
        assert isinstance(pkt, Packet)
        if (pkt.proto == IP_PROTOS.tcp):
            break
    print(pkt)

    tcp_ack = Ether(dst=dut_mac, src=tb_mac) / pkt

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_ack.build()))

    tb.log.info("Expecting to send an F here")

    while True:
        pkt = t.recv()
        assert isinstance(pkt, Packet)
        if (pkt.proto == IP_PROTOS.tcp):
            break
    print(pkt)

    tcp_fin = Ether(dst=dut_mac, src=tb_mac) / pkt

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_fin.build()))

    tb.log.info("Expecting to get ACK from DUT")

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)

    tb.log.info("Expecting to get FINACK from DUT")

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)

    tb.log.info("Expecting to get ACK from host")

    while True:
        pkt = t.recv()
        assert isinstance(pkt, Packet)
        if (pkt.proto == IP_PROTOS.tcp):
            break
    print(pkt)

    tcp_fin = Ether(dst=dut_mac, src=tb_mac) / pkt

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_fin.build()))

    await Timer(Decimal(CLK_PERIOD_NS * 1000), units='ns')


@cocotb.test()
async def test_close(dut):
    tb = TB(dut)

    async def read_tcp_from_dut():
        resp = await tb.mii_phy.tx.recv() # type: GmiiFrame
        packet = Ether(resp.get_payload())
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

        return ip_packet

    def get_pkt_from_host():
        while True:
            pkt = t.recv()
            assert isinstance(pkt, Packet)
            if (pkt.proto == IP_PROTOS.tcp):
                break
        print(pkt)
        return pkt

    #############################
    # Reset DUT                 #
    #############################


    await tb.cycle_reset()

    dut_ip = "172.0.0.2"
    tb_ip = "172.0.0.1"

    tb_mac = "02:00:00:11:22:33"

    dut_port = random.randint(1024, 65535)
    tb_port = random.randint(1024, 65535)

    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind((tb_ip, tb_port))
    serversocket.listen(1)
    t = TunTapInterface('tun0')


    ###############################
    # Configure DUT Network block #
    ###############################

    await tb.axil_master.write_dword(0x0, 0x1807)

    await tb.axil_master.write_dword(0x200, dut_port)
    await tb.axil_master.write_dword(0x204, ip_to_hex(dut_ip))
    await tb.axil_master.write_dword(0x208, tb_port)
    await tb.axil_master.write_dword(0x20c, ip_to_hex(tb_ip))
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

    dut_mac = arp_request.hwsrc
    dut_ip = arp_request.psrc

    assert arp_request.op == 1, "ARP type is not request!"
    assert arp_request.hwsrc == "02:00:00:aa:bb:cc", "ARP hwsrc does not match expected"
    assert arp_request.hwdst == "00:00:00:00:00:00", "ARP hwdst does not match expected"
    assert arp_request.psrc == dut_ip, "ARP psrc does not match expected"
    assert arp_request.pdst == tb_ip, "ARP pdst does not match expected"

    # hardcode the ARP response for now
    arp_response = Ether(dst=dut_mac, src=tb_mac)
    arp_response /= ARP(op="is-at", hwsrc=tb_mac, hwdst=dut_mac, psrc=tb_ip, pdst=dut_ip)
    arp_response = arp_response.build()

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(arp_response))


    ###############################
    # Start TCP handshake         #
    ###############################

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)


    pkt = get_pkt_from_host()
    tcp_synack = Ether(dst=dut_mac, src=tb_mac)  / pkt

    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_synack.build()))

    ip_packet = await read_tcp_from_dut()

    t.send(ip_packet)

    con, addr = serversocket.accept()

    tb.log.info(f"con_timeout: {con.timeout}")

    ###############################
    # Close connection from DUT   #
    ###############################

    tb.log.info("Closing connection from the DUT side")
    await tb.axil_master.write_dword(0x210, 5)

    ip_packet = await read_tcp_from_dut()

    tb.log.info("Sending packet to host")
    t.send(ip_packet)

    pkt = get_pkt_from_host()
    tcp_synack = Ether(dst=dut_mac, src=tb_mac)  / pkt

    tb.log.info("Sending reply to DUT, this should be an ACK?")
    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_synack.build()))

    tb.log.info(tcp_synack.flags)

    # Host will send an ack first, then a finack?

    tb.log.info("Closing server socket")
    con.close()
    serversocket.close()

    pkt = get_pkt_from_host()
    tcp_synack = Ether(dst=dut_mac, src=tb_mac)  / pkt

    tb.log.info("Sending packet to DUT, this should be a FINACK?")
    await tb.mii_phy.rx.send(GmiiFrame.from_payload(tcp_synack.build()))

    pkt = get_pkt_from_host()
    tcp_synack = Ether(dst=dut_mac, src=tb_mac)  / pkt

    ip_packet = await read_tcp_from_dut()

    tb.log.info("Sending packet to host")
    t.send(ip_packet)

    await Timer(Decimal(CLK_PERIOD_NS * 20000), units='ns')