#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3356" "34224" "3549" "13335" "3303" )
# node_array must be countinus mubers
pid_array=()
for node_num in ${node_array[*]}                
do                
    temp=$(sudo docker inspect -f '{{.State.Pid}}' node_$node_num)                
    ln -s /proc/$temp/ns/net /var/run/netns/$temp                
    pid_array+=($temp)                
done                
                
funCreateV(){                
    # para 1: local node in letter, must be lowercase;a                
    # para 2: peer node in letter, must be lowercase;b                
    # para 3: local node in number,;1                
    # para 4: peer node in number,2                
    # para 5: the IP addr of the local node interface                
    # para 6: the IP addr of the peer node interface                
    PID_L=${pid_array[$3]}                
    PID_P=${pid_array[$4]}                
    NET_L=$1                
    NET_P=$2                
    ip link add ${NET_L} type veth peer name ${NET_P}                
    ip link set ${NET_L}  netns ${PID_L}                
    ip link set ${NET_P}  netns ${PID_P}                
    ip netns exec ${PID_L} ip addr add ${5} dev ${NET_L}                
    ip netns exec ${PID_L} ip link set ${NET_L} up                
    ip netns exec ${PID_P} ip addr add ${6} dev ${NET_P}                
    ip netns exec ${PID_P} ip link set ${NET_P} up                
}                
funCreateClusterV(){                
    # para 1: local node in letter, must be lowercase;a                
    # para 2: peer node in letter, must be lowercase;b                
    # para 3: local node in number,;1                
    # para 4: peer node in number,2                
    # para 5: the IP addr of the local node interface                
    # para 6: the IP addr of the peer node interface                
    PID_L=${pid_array[$3]}                
    NET_L=$1                
    NET_P=$2                
    ip link add ${NET_L} type veth peer name ${NET_P}                
    ip link set ${NET_L}  netns ${PID_L}                
    ip netns exec ${PID_L} ip addr add ${5} dev ${NET_L}                
    ip netns exec ${PID_L} ip link set ${NET_L} up                
    ip link set dev ${NET_P} master savop_bridge                
    ip link set ${NET_P} up                
}
# node_3356-34224                                
echo "adding host edge node_3356-34224"                                
sleep 0.2                                
funCreateV 'eth_3356_34224' 'eth_34224_3356' '0' '1' '10.0.0.1/24' '10.0.0.2/24'
# node_3356-3549                                
echo "adding host edge node_3356-3549"                                
sleep 0.2                                
funCreateV 'eth_3356_3549' 'eth_3549_3356' '0' '2' '10.0.1.1/24' '10.0.1.2/24'
# node_3356-13335                                
echo "adding host edge node_3356-13335"                                
sleep 0.2                                
funCreateV 'eth_3356_13335' 'eth_13335_3356' '0' '3' '10.0.2.1/24' '10.0.2.2/24'
# node_3356-3303                                
echo "adding host edge node_3356-3303"                                
sleep 0.2                                
funCreateV 'eth_3356_3303' 'eth_3303_3356' '0' '4' '10.0.3.1/24' '10.0.3.2/24'
# node_3356-209                                
echo "adding cluster edge node_3356-209"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_209' 'eth_209_3356' '0' 'None' '10.0.4.1/24' '10.0.4.2/24'
# node_3356-1299                                
echo "adding cluster edge node_3356-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_1299' 'eth_1299_3356' '0' 'None' '10.0.5.1/24' '10.0.5.2/24'
# node_3356-174                                
echo "adding cluster edge node_3356-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_174' 'eth_174_3356' '0' 'None' '10.0.6.1/24' '10.0.6.2/24'
# node_3356-7018                                
echo "adding cluster edge node_3356-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_7018' 'eth_7018_3356' '0' 'None' '10.0.7.1/24' '10.0.7.2/24'
# node_3356-2519                                
echo "adding cluster edge node_3356-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_2519' 'eth_2519_3356' '0' 'None' '10.0.8.1/24' '10.0.8.2/24'
# node_34224-13335                                
echo "adding host edge node_34224-13335"                                
sleep 0.2                                
funCreateV 'eth_34224_13335' 'eth_13335_34224' '1' '3' '10.0.59.1/24' '10.0.59.2/24'
# node_13335-7018                                
echo "adding cluster edge node_13335-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_7018' 'eth_7018_13335' '3' 'None' '10.0.82.1/24' '10.0.82.2/24'
# node_13335-1299                                
echo "adding cluster edge node_13335-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_1299' 'eth_1299_13335' '3' 'None' '10.0.92.1/24' '10.0.92.2/24'
# node_3303-174                                
echo "adding cluster edge node_3303-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_174' 'eth_174_3303' '4' 'None' '10.1.38.1/24' '10.1.38.2/24'