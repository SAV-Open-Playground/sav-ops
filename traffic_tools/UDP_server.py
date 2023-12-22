# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     UDP_server
   Description :
   Author :       ustb_
   date：          2023/7/13
-------------------------------------------------
   Change Activity:
                   2023/7/13:
-------------------------------------------------
"""
import socket
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--dst')
parser.add_argument('--trans_num', type=int)
args = parser.parse_args()
dst, trans_num = args.dst, args.trans_num


udpsever = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udpsever.bind((dst, 12345))
udpsever.settimeout(3)

content_list = []
try:
    while True:
        data, addr = udpsever.recvfrom(1024)
        # senddata = (data.decode("utf-8") + str(time.time())).encode("utf-8")
        receive_content = f'from({addr}_{data.decode("utf-8")}'
        content_list.append(receive_content)
        if len(content_list) == trans_num:
            send_count, success_count, fail_count = trans_num, len(content_list), trans_num - len(content_list)
            print({"send_count": send_count, "success_count": success_count, "fail_count": fail_count})
            break
except socket.timeout:
    send_count, success_count, fail_count = trans_num, len(content_list), trans_num - len(content_list)
    print({"send_count": send_count, "success_count": success_count, "fail_count": fail_count})
finally:
    udpsever.close()