#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("209" "1299" "174" "7018" "2519" )
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
# node_209-3356                                
echo "adding cluster edge node_209-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_209_3356' 'eth_3356_209' '0' 'None' '10.0.4.2/24' '10.0.4.1/24'
# node_1299-13335                                
echo "adding cluster edge node_1299-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_13335' 'eth_13335_1299' '1' 'None' '10.0.92.2/24' '10.0.92.1/24'
# node_1299-7018                                
echo "adding host edge node_1299-7018"                                
sleep 0.2                                
funCreateV 'eth_1299_7018' 'eth_7018_1299' '1' '3' '10.0.102.2/24' '10.0.102.1/24'
# node_1299-3356                                
echo "adding cluster edge node_1299-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_3356' 'eth_3356_1299' '1' 'None' '10.0.5.2/24' '10.0.5.1/24'
# node_1299-2519                                
echo "adding host edge node_1299-2519"                                
sleep 0.2                                
funCreateV 'eth_1299_2519' 'eth_2519_1299' '1' '4' '10.0.237.1/24' '10.0.237.2/24'
# node_1299-174                                
echo "adding host edge node_1299-174"                                
sleep 0.2                                
funCreateV 'eth_1299_174' 'eth_174_1299' '1' '2' '10.0.249.1/24' '10.0.249.2/24'
# node_174-3356                                
echo "adding cluster edge node_174-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3356' 'eth_3356_174' '2' 'None' '10.0.6.2/24' '10.0.6.1/24'
# node_174-2519                                
echo "adding host edge node_174-2519"                                
sleep 0.2                                
funCreateV 'eth_174_2519' 'eth_2519_174' '2' '4' '10.2.56.1/24' '10.2.56.2/24'
# node_174-7018                                
echo "adding host edge node_174-7018"                                
sleep 0.2                                
funCreateV 'eth_174_7018' 'eth_7018_174' '2' '3' '10.0.109.2/24' '10.0.109.1/24'
# node_174-3303                                
echo "adding cluster edge node_174-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3303' 'eth_3303_174' '2' 'None' '10.1.38.2/24' '10.1.38.1/24'
# node_7018-13335                                
echo "adding cluster edge node_7018-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_13335' 'eth_13335_7018' '3' 'None' '10.0.82.2/24' '10.0.82.1/24'
# node_7018-3356                                
echo "adding cluster edge node_7018-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_3356' 'eth_3356_7018' '3' 'None' '10.0.7.2/24' '10.0.7.1/24'
# node_2519-3356                                
echo "adding cluster edge node_2519-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2519_3356' 'eth_3356_2519' '4' 'None' '10.0.8.2/24' '10.0.8.1/24'