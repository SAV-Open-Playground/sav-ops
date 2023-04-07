#!/usr/bin/bash
docker exec --privileged test_sender iperf -c 192.168.4.100 -b 7M  -i 1  -w 1M  -t 20 
