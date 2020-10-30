#!/usr/bin/env python
import sys
import struct
import os

import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

from scapy.all import sniff, sendp, hexdump, get_if_list, get_if_hwaddr
from scapy.all import Packet, IPOption
from scapy.all import ShortField, IntField, LongField, BitField, FieldListField, FieldLenField
from scapy.all import IP, TCP, UDP, Raw
from scapy.layers.inet import _IPOption_HDR


class Port_Validation(Packet):
    name = "Port Validation"
    fields_desc = [
        BitField('switch_num',0 , 3),
        BitField('in_out', 0 , 1),
        BitField('port_num', 0 , 9),
        BitField('padding', 0 , 3),
    ]


def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface



def handle_pkt(pkt):
    if UDP in pkt and pkt[UDP].sport == 10000 and pkt[UDP].dport == 20000:

        payload = bytes(pkt[UDP].payload)
        if len(payload) == 0:
            print("UDP packet captured but no telemetry information in it.")
            return

        if pkt[UDP].len == 8 & len(payload) > 0:
            print("UDP header wrong size. Telemetry information detected but "
                   "UDP length has not been modified.")
            return

        print("Captured UDP packet with telemetry.")
        p_bytes = pkt[UDP].len - 8
        #print(p_bytes)

        for i in xrange(0,p_bytes,4):
            start_byte = i
            end_byte = i + 2
            inPort = Port_Validation(payload[start_byte : end_byte])
            outPort = Port_Validation(payload[end_byte : end_byte + 2])
            print("inPort(%d) -> Switch(%d) -> outPort(%d)" % \
            ( int(inPort.port_num) , int(inPort.switch_num), int(outPort.port_num)))

        #pkt.show2()
        #hexdump(pkt)
        sys.stdout.flush()


def main():
    ifaces = filter(lambda i: 'eth' in i, os.listdir('/sys/class/net/'))
    iface = ifaces[0]
    print "Listening for UDP packets on %s interface:" % iface
    sys.stdout.flush()
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
