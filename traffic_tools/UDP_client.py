# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name     UDP_server
   Description : For traffic testing
   date:         2023/7/14
-------------------------------------------------
"""
from scapy.all import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--dst')
parser.add_argument('--src')
parser.add_argument('--iface')
parser.add_argument('--trans_num', type=int, default=10)
args = parser.parse_args()
dst, src, iface, trans_num = args.dst, args.src, args.iface, args.trans_num


def get_dst_mac(src_inf):
    local_ip = get_if_addr(src_inf)
    peer_ip = local_ip
    # TODO get peer ip properly
    if peer_ip.endswith("2"):
        peer_ip = peer_ip[:-1] + '1'
    else:
        peer_ip = peer_ip[:-1] + '2'
    return getmacbyip(peer_ip)


dst_mac = get_dst_mac(iface)
for i in range(trans_num):
    p = Ether(dst=dst_mac) / IP(src=src, dst=dst) / UDP(sport=54321, dport=12345) / Raw(str(i).encode("utf-8"))
    sendp(p, iface=iface, verbose=True)