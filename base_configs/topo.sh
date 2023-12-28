#!/usr/bin/bash
funCreateV4(){
    # para 1: the tag of src node, 
    # para 2: the tag of dst node
    # para 3: the IP addr of the local node interface 
    # para 4: the IP addr of the peer node interface    
    PID_L=$(sudo docker inspect -f '{{.State.Pid}}' $1)
    PID_P=$(sudo docker inspect -f '{{.State.Pid}}' $2)
    # echo "PID: $PID_P $PID_L"
    ln -sf /proc/$PID_L/ns/net /var/run/netns/$PID_L    
    ln -sf /proc/$PID_P/ns/net /var/run/netns/$PID_P
    
    
    NET_L="eth_`echo ${2}|awk -F"r" '{ print $NF }'`"
    NET_P="eth_`echo ${1}|awk -F"r" '{ print $NF }'`"
    ip link add ${NET_L} type veth peer name ${NET_P}
    ip link set ${NET_L}  netns ${PID_L}
    ip link set ${NET_P}  netns ${PID_P}
    ip netns exec ${PID_L} ip addr flush ${NET_L}
    ip netns exec ${PID_L} ip addr add ${3} dev ${NET_L}
    ip netns exec ${PID_L} ip link set ${NET_L} up
    ip netns exec ${PID_P} ip addr flush ${NET_P}
    ip netns exec ${PID_P} ip addr add ${4} dev ${NET_P}
    ip netns exec ${PID_P} ip link set ${NET_P} up
    echo "$1_$2 added"
}
funCreateV6(){
    # para 1: the tag of src node, 
    # para 2: the tag of dst node
    # para 3: the IP addr of the local node interface 
    # para 4: the IP addr of the peer node interface    
    PID_L=$(sudo docker inspect -f '{{.State.Pid}}' $1)
    PID_P=$(sudo docker inspect -f '{{.State.Pid}}' $2)
    # echo "PID: $PID_P $PID_L"
    ln -sf /proc/$PID_L/ns/net /var/run/netns/$PID_L    
    ln -sf /proc/$PID_P/ns/net /var/run/netns/$PID_P
    
    
    NET_L="eth_`echo ${2}|awk -F"r" '{ print $NF }'`"
    NET_P="eth_`echo ${1}|awk -F"r" '{ print $NF }'`"

    ip link add ${NET_L} type veth peer name ${NET_P}
    ip link set ${NET_L}  netns ${PID_L}
    ip link set ${NET_P}  netns ${PID_P}
    ip netns exec ${PID_L} ip addr flush ${NET_L}
    ip netns exec ${PID_L} ip -6 addr add ${3} dev ${NET_L}
    ip netns exec ${PID_L} ip link set ${NET_L} up
    ip netns exec ${PID_P} ip addr flush ${NET_P}
    ip netns exec ${PID_P} ip -6 addr add ${4} dev ${NET_P}
    ip netns exec ${PID_P} ip link set ${NET_P} up
    echo "$1_$2 added"
}