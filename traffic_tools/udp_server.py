# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name     UDP_server
   Description : For traffic testing
   Author :      yuqian.shi@outlook.com
   date:         2023/7/14
-------------------------------------------------
"""
import socket
import time
import sys
if len(sys.argv)!=2:
    print(f'please input listening addr( e.g. python3 {sys.argv[0]} 192.168.1.1:12345)')
    sys.exit(-1)
addr = sys.argv[1].split(":")
ip = addr[0]
port = int(addr[1])
udpsever = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udpsever.bind((ip, port))
print(f'listening on {ip}:{port}')
while True:
    data, addr = udpsever.recvfrom(1024)
    data=data.decode("utf-8")
    print("from", addr, "data", data,"at",time.time())