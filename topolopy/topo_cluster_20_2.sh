#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3257" "3741" "2914" "6762" "2516" "38040" "2152" "5511" "293" "4837" )
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
# node_3257-13335                                
echo "adding cluster edge node_3257-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_13335' 'eth_13335_3257' '0' 'None' '10.0.84.2/24' '10.0.84.1/24'
# node_3257-1299                                
echo "adding cluster edge node_3257-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_1299' 'eth_1299_3257' '0' 'None' '10.0.125.1/24' '10.0.125.2/24'
# node_3257-3356                                
echo "adding cluster edge node_3257-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_3356' 'eth_3356_3257' '0' 'None' '10.0.9.2/24' '10.0.9.1/24'
# node_3257-2914                                
echo "adding host edge node_3257-2914"                                
sleep 0.2                                
funCreateV 'eth_3257_2914' 'eth_2914_3257' '0' '2' '10.0.126.1/24' '10.0.126.2/24'
# node_3257-4837                                
echo "adding host edge node_3257-4837"                                
sleep 0.2                                
funCreateV 'eth_3257_4837' 'eth_4837_3257' '0' '9' '10.0.130.1/24' '10.0.130.2/24'
# node_3257-174                                
echo "adding cluster edge node_3257-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_174' 'eth_174_3257' '0' 'None' '10.0.134.1/24' '10.0.134.2/24'
# node_3257-7018                                
echo "adding cluster edge node_3257-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_7018' 'eth_7018_3257' '0' 'None' '10.0.118.2/24' '10.0.118.1/24'
# node_3257-3303                                
echo "adding cluster edge node_3257-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_3303' 'eth_3303_3257' '0' 'None' '10.0.149.1/24' '10.0.149.2/24'
# node_3257-5511                                
echo "adding host edge node_3257-5511"                                
sleep 0.2                                
funCreateV 'eth_3257_5511' 'eth_5511_3257' '0' '7' '10.0.152.1/24' '10.0.152.2/24'
# node_3257-6762                                
echo "adding host edge node_3257-6762"                                
sleep 0.2                                
funCreateV 'eth_3257_6762' 'eth_6762_3257' '0' '3' '10.0.154.1/24' '10.0.154.2/24'
# node_3741-13335                                
echo "adding cluster edge node_3741-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_13335' 'eth_13335_3741' '1' 'None' '10.0.86.2/24' '10.0.86.1/24'
# node_3741-3356                                
echo "adding cluster edge node_3741-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_3356' 'eth_3356_3741' '1' 'None' '10.0.10.2/24' '10.0.10.1/24'
# node_3741-174                                
echo "adding cluster edge node_3741-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_174' 'eth_174_3741' '1' 'None' '10.0.163.1/24' '10.0.163.2/24'
# node_3741-2914                                
echo "adding host edge node_3741-2914"                                
sleep 0.2                                
funCreateV 'eth_3741_2914' 'eth_2914_3741' '1' '2' '10.0.166.1/24' '10.0.166.2/24'
# node_2914-13335                                
echo "adding cluster edge node_2914-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_13335' 'eth_13335_2914' '2' 'None' '10.0.98.2/24' '10.0.98.1/24'
# node_2914-293                                
echo "adding host edge node_2914-293"                                
sleep 0.2                                
funCreateV 'eth_2914_293' 'eth_293_2914' '2' '8' '10.1.171.2/24' '10.1.171.1/24'
# node_2914-3356                                
echo "adding cluster edge node_2914-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_3356' 'eth_3356_2914' '2' 'None' '10.0.11.2/24' '10.0.11.1/24'
# node_2914-7018                                
echo "adding cluster edge node_2914-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_7018' 'eth_7018_2914' '2' 'None' '10.0.103.2/24' '10.0.103.1/24'
# node_2914-38040                                
echo "adding host edge node_2914-38040"                                
sleep 0.2                                
funCreateV 'eth_2914_38040' 'eth_38040_2914' '2' '5' '10.1.198.1/24' '10.1.198.2/24'
# node_2914-4837                                
echo "adding host edge node_2914-4837"                                
sleep 0.2                                
funCreateV 'eth_2914_4837' 'eth_4837_2914' '2' '9' '10.1.200.1/24' '10.1.200.2/24'
# node_2914-1299                                
echo "adding cluster edge node_2914-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_1299' 'eth_1299_2914' '2' 'None' '10.0.245.2/24' '10.0.245.1/24'
# node_2914-3303                                
echo "adding cluster edge node_2914-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_3303' 'eth_3303_2914' '2' 'None' '10.1.37.2/24' '10.1.37.1/24'
# node_2914-174                                
echo "adding cluster edge node_2914-174"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_174' 'eth_174_2914' '2' 'None' '10.1.208.1/24' '10.1.208.2/24'
# node_2914-6762                                
echo "adding host edge node_2914-6762"                                
sleep 0.2                                
funCreateV 'eth_2914_6762' 'eth_6762_2914' '2' '3' '10.1.220.1/24' '10.1.220.2/24'
# node_2914-5511                                
echo "adding host edge node_2914-5511"                                
sleep 0.2                                
funCreateV 'eth_2914_5511' 'eth_5511_2914' '2' '7' '10.1.238.1/24' '10.1.238.2/24'
# node_6762-3356                                
echo "adding cluster edge node_6762-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_3356' 'eth_3356_6762' '3' 'None' '10.0.12.2/24' '10.0.12.1/24'
# node_6762-1299                                
echo "adding cluster edge node_6762-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_1299' 'eth_1299_6762' '3' 'None' '10.0.252.2/24' '10.0.252.1/24'
# node_6762-38040                                
echo "adding host edge node_6762-38040"                                
sleep 0.2                                
funCreateV 'eth_6762_38040' 'eth_38040_6762' '3' '5' '10.2.170.1/24' '10.2.170.2/24'
# node_6762-34224                                
echo "adding cluster edge node_6762-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_34224' 'eth_34224_6762' '3' 'None' '10.0.72.2/24' '10.0.72.1/24'
# node_6762-5511                                
echo "adding host edge node_6762-5511"                                
sleep 0.2                                
funCreateV 'eth_6762_5511' 'eth_5511_6762' '3' '7' '10.2.177.1/24' '10.2.177.2/24'
# node_6762-7018                                
echo "adding cluster edge node_6762-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_7018' 'eth_7018_6762' '3' 'None' '10.0.120.2/24' '10.0.120.1/24'
# node_6762-174                                
echo "adding cluster edge node_6762-174"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_174' 'eth_174_6762' '3' 'None' '10.2.81.2/24' '10.2.81.1/24'
# node_2516-2152                                
echo "adding host edge node_2516-2152"                                
sleep 0.2                                
funCreateV 'eth_2516_2152' 'eth_2152_2516' '4' '6' '10.1.61.2/24' '10.1.61.1/24'
# node_2516-3356                                
echo "adding cluster edge node_2516-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2516_3356' 'eth_3356_2516' '4' 'None' '10.0.13.2/24' '10.0.13.1/24'
# node_38040-3356                                
echo "adding cluster edge node_38040-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_3356' 'eth_3356_38040' '5' 'None' '10.0.14.2/24' '10.0.14.1/24'
# node_38040-34224                                
echo "adding cluster edge node_38040-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_34224' 'eth_34224_38040' '5' 'None' '10.0.62.2/24' '10.0.62.1/24'
# node_38040-1299                                
echo "adding cluster edge node_38040-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_1299' 'eth_1299_38040' '5' 'None' '10.0.241.2/24' '10.0.241.1/24'
# node_38040-3303                                
echo "adding cluster edge node_38040-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_3303' 'eth_3303_38040' '5' 'None' '10.1.32.2/24' '10.1.32.1/24'
# node_38040-174                                
echo "adding cluster edge node_38040-174"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_174' 'eth_174_38040' '5' 'None' '10.2.65.2/24' '10.2.65.1/24'
# node_38040-293                                
echo "adding host edge node_38040-293"                                
sleep 0.2                                
funCreateV 'eth_38040_293' 'eth_293_38040' '5' '8' '10.1.182.2/24' '10.1.182.1/24'
# node_2152-13335                                
echo "adding cluster edge node_2152-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_13335' 'eth_13335_2152' '6' 'None' '10.0.93.2/24' '10.0.93.1/24'
# node_2152-3356                                
echo "adding cluster edge node_2152-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_3356' 'eth_3356_2152' '6' 'None' '10.0.15.2/24' '10.0.15.1/24'
# node_5511-7018                                
echo "adding cluster edge node_5511-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_7018' 'eth_7018_5511' '7' 'None' '10.0.106.2/24' '10.0.106.1/24'
# node_5511-4837                                
echo "adding host edge node_5511-4837"                                
sleep 0.2                                
funCreateV 'eth_5511_4837' 'eth_4837_5511' '7' '9' '10.3.8.2/24' '10.3.8.1/24'
# node_5511-3356                                
echo "adding cluster edge node_5511-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_3356' 'eth_3356_5511' '7' 'None' '10.0.16.2/24' '10.0.16.1/24'
# node_5511-174                                
echo "adding cluster edge node_5511-174"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_174' 'eth_174_5511' '7' 'None' '10.2.57.2/24' '10.2.57.1/24'
# node_5511-1299                                
echo "adding cluster edge node_5511-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_1299' 'eth_1299_5511' '7' 'None' '10.1.26.2/24' '10.1.26.1/24'
# node_293-13335                                
echo "adding cluster edge node_293-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_293_13335' 'eth_13335_293' '8' 'None' '10.0.96.2/24' '10.0.96.1/24'
# node_293-3356                                
echo "adding cluster edge node_293-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_293_3356' 'eth_3356_293' '8' 'None' '10.0.17.2/24' '10.0.17.1/24'
# node_4837-1299                                
echo "adding cluster edge node_4837-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_1299' 'eth_1299_4837' '9' 'None' '10.0.243.2/24' '10.0.243.1/24'
# node_4837-3303                                
echo "adding cluster edge node_4837-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_3303' 'eth_3303_4837' '9' 'None' '10.1.34.2/24' '10.1.34.1/24'
# node_4837-7018                                
echo "adding cluster edge node_4837-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_7018' 'eth_7018_4837' '9' 'None' '10.0.107.2/24' '10.0.107.1/24'
# node_4837-3356                                
echo "adding cluster edge node_4837-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_3356' 'eth_3356_4837' '9' 'None' '10.0.18.2/24' '10.0.18.1/24'
# node_4837-174                                
echo "adding cluster edge node_4837-174"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_174' 'eth_174_4837' '9' 'None' '10.2.79.2/24' '10.2.79.1/24'