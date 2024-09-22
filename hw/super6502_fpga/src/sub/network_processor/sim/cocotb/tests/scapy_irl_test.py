from scapy.layers.inet import Ether, IP, TCP
from scapy.layers.l2 import ARP

from scapy import sendrecv

from scapy.config import conf

from scapy.supersocket import L3RawSocket


import socket

# In order for this to work, you need to run these commands:
# sudo setcap cap_net_raw=eip $(readlink -f $(which python))
# sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -s 127.0.0.1 -j DROP

def main():
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.bind(("127.0.0.1", 5678))
    serversocket.listen(5)

    conf.L3socket = L3RawSocket

    tcp_syn = IP(dst="127.0.0.1")/TCP(sport=1234, dport=5678, seq=0, ack=0, flags="S")
    sendrecv.send(tcp_syn, iface="lo")

    pkt = sendrecv.sniff(filter="tcp src port 5678", iface="lo", count=1)[0]
    print(pkt)


if __name__ == "__main__":
    main()