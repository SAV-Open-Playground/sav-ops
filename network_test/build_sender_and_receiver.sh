#!/usr/bin/bash
set -ex
SENDER_NET="192.168.2"
REIVER_NET="192.168.4"
docker build -f ../Dockerfile_Test . -t savop_test
docker run -itd --net none --name=test_receiver savop_test /bin/bash
docker run -itd --net none --name=test_sender savop_test /bin/bash

sender_pid=`docker inspect -f '{{.State.Pid}}'  test_sender`
ln -s /proc/${sender_pid}/ns/net /var/run/netns/${sender_pid}
ip link add test_sender type veth peer name test_bridge
ip link set test_sender netns ${sender_pid}
ip netns exec ${sender_pid} ip addr add ${SENDER_NET}.100 dev test_sender
ip netns exec ${sender_pid} ip link set test_sender up
node_start=`docker ps|grep node| awk '{ print $11 }' | sort | head -n 1`
node_start_pid=`docker inspect -f '{{.State.Pid}}'  ${node_start}`
ip link set test_bridge netns ${node_start_pid}
ip netns exec ${node_start_pid} ip addr add ${SENDER_NET}.200 dev test_bridge
ip netns exec ${node_start_pid} ip link set test_bridge up
docker exec --privileged test_sender route add -net ${SENDER_NET}.0/24 dev test_sender
docker exec --privileged test_sender route add default gw ${SENDER_NET}.200
docker exec --privileged ${node_start} route add -host ${SENDER_NET}.100 dev test_bridge


receiver_pid=`docker inspect -f '{{.State.Pid}}'  test_receiver`
ln -s /proc/${receiver_pid}/ns/net /var/run/netns/${receiver_pid}
ip link add test_receiver type veth peer name test_bridge
ip link set test_receiver netns ${receiver_pid}
ip netns exec ${receiver_pid} ip addr add ${REIVER_NET}.100 dev test_receiver
ip netns exec ${receiver_pid} ip link set test_receiver up
node_end=`docker ps|grep node| awk '{ print $11 }' | sort | tail -n 1`
node_end_pid=`docker inspect -f '{{.State.Pid}}'  ${node_end}`
ip link set test_bridge netns ${node_end_pid}
ip netns exec ${node_end_pid} ip addr add ${REIVER_NET}.200 dev test_bridge
ip netns exec ${node_end_pid} ip link set test_bridge up
docker exec --privileged test_receiver route add -net ${REIVER_NET}.0/24 dev test_receiver
docker exec --privileged test_receiver route add default gw ${REIVER_NET}.200
docker exec --privileged ${node_end} route add -host ${REIVER_NET}.100 dev test_bridge

