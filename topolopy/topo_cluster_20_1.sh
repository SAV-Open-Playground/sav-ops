#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3356" "34224" "3549" "13335" "3303" "209" "1299" "174" "7018" "2519" )
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
echo "adding host edge node_3356-209"                                
sleep 0.2                                
funCreateV 'eth_3356_209' 'eth_209_3356' '0' '5' '10.0.4.1/24' '10.0.4.2/24'
# node_3356-1299                                
echo "adding host edge node_3356-1299"                                
sleep 0.2                                
funCreateV 'eth_3356_1299' 'eth_1299_3356' '0' '6' '10.0.5.1/24' '10.0.5.2/24'
# node_3356-174                                
echo "adding host edge node_3356-174"                                
sleep 0.2                                
funCreateV 'eth_3356_174' 'eth_174_3356' '0' '7' '10.0.6.1/24' '10.0.6.2/24'
# node_3356-7018                                
echo "adding host edge node_3356-7018"                                
sleep 0.2                                
funCreateV 'eth_3356_7018' 'eth_7018_3356' '0' '8' '10.0.7.1/24' '10.0.7.2/24'
# node_3356-2519                                
echo "adding host edge node_3356-2519"                                
sleep 0.2                                
funCreateV 'eth_3356_2519' 'eth_2519_3356' '0' '9' '10.0.8.1/24' '10.0.8.2/24'
# node_3356-3257                                
echo "adding cluster edge node_3356-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_3257' 'eth_3257_3356' '0' 'None' '10.0.9.1/24' '10.0.9.2/24'
# node_3356-3741                                
echo "adding cluster edge node_3356-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_3741' 'eth_3741_3356' '0' 'None' '10.0.10.1/24' '10.0.10.2/24'
# node_3356-2914                                
echo "adding cluster edge node_3356-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_2914' 'eth_2914_3356' '0' 'None' '10.0.11.1/24' '10.0.11.2/24'
# node_3356-6762                                
echo "adding cluster edge node_3356-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_6762' 'eth_6762_3356' '0' 'None' '10.0.12.1/24' '10.0.12.2/24'
# node_3356-2516                                
echo "adding cluster edge node_3356-2516"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_2516' 'eth_2516_3356' '0' 'None' '10.0.13.1/24' '10.0.13.2/24'
# node_3356-38040                                
echo "adding cluster edge node_3356-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_38040' 'eth_38040_3356' '0' 'None' '10.0.14.1/24' '10.0.14.2/24'
# node_3356-2152                                
echo "adding cluster edge node_3356-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_2152' 'eth_2152_3356' '0' 'None' '10.0.15.1/24' '10.0.15.2/24'
# node_3356-5511                                
echo "adding cluster edge node_3356-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_5511' 'eth_5511_3356' '0' 'None' '10.0.16.1/24' '10.0.16.2/24'
# node_3356-293                                
echo "adding cluster edge node_3356-293"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_293' 'eth_293_3356' '0' 'None' '10.0.17.1/24' '10.0.17.2/24'
# node_3356-4837                                
echo "adding cluster edge node_3356-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4837' 'eth_4837_3356' '0' 'None' '10.0.18.1/24' '10.0.18.2/24'
# node_34224-13335                                
echo "adding host edge node_34224-13335"                                
sleep 0.2                                
funCreateV 'eth_34224_13335' 'eth_13335_34224' '1' '3' '10.0.59.1/24' '10.0.59.2/24'
# node_34224-38040                                
echo "adding cluster edge node_34224-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_38040' 'eth_38040_34224' '1' 'None' '10.0.62.1/24' '10.0.62.2/24'
# node_34224-6762                                
echo "adding cluster edge node_34224-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_6762' 'eth_6762_34224' '1' 'None' '10.0.72.1/24' '10.0.72.2/24'
# node_13335-7018                                
echo "adding host edge node_13335-7018"                                
sleep 0.2                                
funCreateV 'eth_13335_7018' 'eth_7018_13335' '3' '8' '10.0.82.1/24' '10.0.82.2/24'
# node_13335-3257                                
echo "adding cluster edge node_13335-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_3257' 'eth_3257_13335' '3' 'None' '10.0.84.1/24' '10.0.84.2/24'
# node_13335-3741                                
echo "adding cluster edge node_13335-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_3741' 'eth_3741_13335' '3' 'None' '10.0.86.1/24' '10.0.86.2/24'
# node_13335-1299                                
echo "adding host edge node_13335-1299"                                
sleep 0.2                                
funCreateV 'eth_13335_1299' 'eth_1299_13335' '3' '6' '10.0.92.1/24' '10.0.92.2/24'
# node_13335-2152                                
echo "adding cluster edge node_13335-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_2152' 'eth_2152_13335' '3' 'None' '10.0.93.1/24' '10.0.93.2/24'
# node_13335-293                                
echo "adding cluster edge node_13335-293"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_293' 'eth_293_13335' '3' 'None' '10.0.96.1/24' '10.0.96.2/24'
# node_13335-2914                                
echo "adding cluster edge node_13335-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_2914' 'eth_2914_13335' '3' 'None' '10.0.98.1/24' '10.0.98.2/24'
# node_3303-38040                                
echo "adding cluster edge node_3303-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_38040' 'eth_38040_3303' '4' 'None' '10.1.32.1/24' '10.1.32.2/24'
# node_3303-4837                                
echo "adding cluster edge node_3303-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_4837' 'eth_4837_3303' '4' 'None' '10.1.34.1/24' '10.1.34.2/24'
# node_3303-2914                                
echo "adding cluster edge node_3303-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_2914' 'eth_2914_3303' '4' 'None' '10.1.37.1/24' '10.1.37.2/24'
# node_3303-174                                
echo "adding host edge node_3303-174"                                
sleep 0.2                                
funCreateV 'eth_3303_174' 'eth_174_3303' '4' '7' '10.1.38.1/24' '10.1.38.2/24'
# node_3303-3257                                
echo "adding cluster edge node_3303-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_3257' 'eth_3257_3303' '4' 'None' '10.0.149.2/24' '10.0.149.1/24'
# node_1299-7018                                
echo "adding host edge node_1299-7018"                                
sleep 0.2                                
funCreateV 'eth_1299_7018' 'eth_7018_1299' '6' '8' '10.0.102.2/24' '10.0.102.1/24'
# node_1299-3257                                
echo "adding cluster edge node_1299-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_3257' 'eth_3257_1299' '6' 'None' '10.0.125.2/24' '10.0.125.1/24'
# node_1299-2519                                
echo "adding host edge node_1299-2519"                                
sleep 0.2                                
funCreateV 'eth_1299_2519' 'eth_2519_1299' '6' '9' '10.0.237.1/24' '10.0.237.2/24'
# node_1299-38040                                
echo "adding cluster edge node_1299-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_38040' 'eth_38040_1299' '6' 'None' '10.0.241.1/24' '10.0.241.2/24'
# node_1299-4837                                
echo "adding cluster edge node_1299-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4837' 'eth_4837_1299' '6' 'None' '10.0.243.1/24' '10.0.243.2/24'
# node_1299-2914                                
echo "adding cluster edge node_1299-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_2914' 'eth_2914_1299' '6' 'None' '10.0.245.1/24' '10.0.245.2/24'
# node_1299-174                                
echo "adding host edge node_1299-174"                                
sleep 0.2                                
funCreateV 'eth_1299_174' 'eth_174_1299' '6' '7' '10.0.249.1/24' '10.0.249.2/24'
# node_1299-6762                                
echo "adding cluster edge node_1299-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_6762' 'eth_6762_1299' '6' 'None' '10.0.252.1/24' '10.0.252.2/24'
# node_1299-5511                                
echo "adding cluster edge node_1299-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_5511' 'eth_5511_1299' '6' 'None' '10.1.26.1/24' '10.1.26.2/24'
# node_174-2519                                
echo "adding host edge node_174-2519"                                
sleep 0.2                                
funCreateV 'eth_174_2519' 'eth_2519_174' '7' '9' '10.2.56.1/24' '10.2.56.2/24'
# node_174-3741                                
echo "adding cluster edge node_174-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3741' 'eth_3741_174' '7' 'None' '10.0.163.2/24' '10.0.163.1/24'
# node_174-5511                                
echo "adding cluster edge node_174-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_174_5511' 'eth_5511_174' '7' 'None' '10.2.57.1/24' '10.2.57.2/24'
# node_174-7018                                
echo "adding host edge node_174-7018"                                
sleep 0.2                                
funCreateV 'eth_174_7018' 'eth_7018_174' '7' '8' '10.0.109.2/24' '10.0.109.1/24'
# node_174-3257                                
echo "adding cluster edge node_174-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3257' 'eth_3257_174' '7' 'None' '10.0.134.2/24' '10.0.134.1/24'
# node_174-2914                                
echo "adding cluster edge node_174-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_174_2914' 'eth_2914_174' '7' 'None' '10.1.208.2/24' '10.1.208.1/24'
# node_174-38040                                
echo "adding cluster edge node_174-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_174_38040' 'eth_38040_174' '7' 'None' '10.2.65.1/24' '10.2.65.2/24'
# node_174-4837                                
echo "adding cluster edge node_174-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_174_4837' 'eth_4837_174' '7' 'None' '10.2.79.1/24' '10.2.79.2/24'
# node_174-6762                                
echo "adding cluster edge node_174-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_174_6762' 'eth_6762_174' '7' 'None' '10.2.81.1/24' '10.2.81.2/24'
# node_7018-2914                                
echo "adding cluster edge node_7018-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_2914' 'eth_2914_7018' '8' 'None' '10.0.103.1/24' '10.0.103.2/24'
# node_7018-5511                                
echo "adding cluster edge node_7018-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_5511' 'eth_5511_7018' '8' 'None' '10.0.106.1/24' '10.0.106.2/24'
# node_7018-4837                                
echo "adding cluster edge node_7018-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_4837' 'eth_4837_7018' '8' 'None' '10.0.107.1/24' '10.0.107.2/24'
# node_7018-3257                                
echo "adding cluster edge node_7018-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_3257' 'eth_3257_7018' '8' 'None' '10.0.118.1/24' '10.0.118.2/24'
# node_7018-6762                                
echo "adding cluster edge node_7018-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_6762' 'eth_6762_7018' '8' 'None' '10.0.120.1/24' '10.0.120.2/24'