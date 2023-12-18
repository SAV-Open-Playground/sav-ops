#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("6762" "2516" "38040" "2152" "5511" "293" "4837" "1273" "1239" "6453" "31133" "64049" )
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
# node_6762-3356                                
echo "adding cluster edge node_6762-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_3356' 'eth_3356_6762' '0' 'None' '10.0.12.2/24' '10.0.12.1/24'
# node_6762-1299                                
echo "adding cluster edge node_6762-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_1299' 'eth_1299_6762' '0' 'None' '10.0.252.2/24' '10.0.252.1/24'
# node_6762-6453                                
echo "adding host edge node_6762-6453"                                
sleep 0.2                                
funCreateV 'eth_6762_6453' 'eth_6453_6762' '0' '9' '10.2.95.2/24' '10.2.95.1/24'
# node_6762-2914                                
echo "adding cluster edge node_6762-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_2914' 'eth_2914_6762' '0' 'None' '10.1.220.2/24' '10.1.220.1/24'
# node_6762-38040                                
echo "adding host edge node_6762-38040"                                
sleep 0.2                                
funCreateV 'eth_6762_38040' 'eth_38040_6762' '0' '2' '10.2.170.1/24' '10.2.170.2/24'
# node_6762-34224                                
echo "adding cluster edge node_6762-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_34224' 'eth_34224_6762' '0' 'None' '10.0.72.2/24' '10.0.72.1/24'
# node_6762-1273                                
echo "adding host edge node_6762-1273"                                
sleep 0.2                                
funCreateV 'eth_6762_1273' 'eth_1273_6762' '0' '7' '10.2.173.1/24' '10.2.173.2/24'
# node_6762-5511                                
echo "adding host edge node_6762-5511"                                
sleep 0.2                                
funCreateV 'eth_6762_5511' 'eth_5511_6762' '0' '4' '10.2.177.1/24' '10.2.177.2/24'
# node_6762-7018                                
echo "adding cluster edge node_6762-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_7018' 'eth_7018_6762' '0' 'None' '10.0.120.2/24' '10.0.120.1/24'
# node_6762-3257                                
echo "adding cluster edge node_6762-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_3257' 'eth_3257_6762' '0' 'None' '10.0.154.2/24' '10.0.154.1/24'
# node_6762-174                                
echo "adding cluster edge node_6762-174"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_174' 'eth_174_6762' '0' 'None' '10.2.81.2/24' '10.2.81.1/24'
# node_6762-1239                                
echo "adding host edge node_6762-1239"                                
sleep 0.2                                
funCreateV 'eth_6762_1239' 'eth_1239_6762' '0' '8' '10.2.34.2/24' '10.2.34.1/24'
# node_2516-2152                                
echo "adding host edge node_2516-2152"                                
sleep 0.2                                
funCreateV 'eth_2516_2152' 'eth_2152_2516' '1' '3' '10.1.61.2/24' '10.1.61.1/24'
# node_2516-3356                                
echo "adding cluster edge node_2516-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2516_3356' 'eth_3356_2516' '1' 'None' '10.0.13.2/24' '10.0.13.1/24'
# node_38040-6453                                
echo "adding host edge node_38040-6453"                                
sleep 0.2                                
funCreateV 'eth_38040_6453' 'eth_6453_38040' '2' '9' '10.2.85.2/24' '10.2.85.1/24'
# node_38040-3356                                
echo "adding cluster edge node_38040-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_3356' 'eth_3356_38040' '2' 'None' '10.0.14.2/24' '10.0.14.1/24'
# node_38040-34224                                
echo "adding cluster edge node_38040-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_34224' 'eth_34224_38040' '2' 'None' '10.0.62.2/24' '10.0.62.1/24'
# node_38040-1299                                
echo "adding cluster edge node_38040-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_1299' 'eth_1299_38040' '2' 'None' '10.0.241.2/24' '10.0.241.1/24'
# node_38040-2914                                
echo "adding cluster edge node_38040-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_2914' 'eth_2914_38040' '2' 'None' '10.1.198.2/24' '10.1.198.1/24'
# node_38040-3303                                
echo "adding cluster edge node_38040-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_3303' 'eth_3303_38040' '2' 'None' '10.1.32.2/24' '10.1.32.1/24'
# node_38040-174                                
echo "adding cluster edge node_38040-174"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_174' 'eth_174_38040' '2' 'None' '10.2.65.2/24' '10.2.65.1/24'
# node_38040-293                                
echo "adding host edge node_38040-293"                                
sleep 0.2                                
funCreateV 'eth_38040_293' 'eth_293_38040' '2' '5' '10.1.182.2/24' '10.1.182.1/24'
# node_2152-13335                                
echo "adding cluster edge node_2152-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_13335' 'eth_13335_2152' '3' 'None' '10.0.93.2/24' '10.0.93.1/24'
# node_2152-1239                                
echo "adding host edge node_2152-1239"                                
sleep 0.2                                
funCreateV 'eth_2152_1239' 'eth_1239_2152' '3' '8' '10.1.60.1/24' '10.1.60.2/24'
# node_2152-3356                                
echo "adding cluster edge node_2152-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_3356' 'eth_3356_2152' '3' 'None' '10.0.15.2/24' '10.0.15.1/24'
# node_5511-7018                                
echo "adding cluster edge node_5511-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_7018' 'eth_7018_5511' '4' 'None' '10.0.106.2/24' '10.0.106.1/24'
# node_5511-4837                                
echo "adding host edge node_5511-4837"                                
sleep 0.2                                
funCreateV 'eth_5511_4837' 'eth_4837_5511' '4' '6' '10.3.8.2/24' '10.3.8.1/24'
# node_5511-3356                                
echo "adding cluster edge node_5511-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_3356' 'eth_3356_5511' '4' 'None' '10.0.16.2/24' '10.0.16.1/24'
# node_5511-174                                
echo "adding cluster edge node_5511-174"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_174' 'eth_174_5511' '4' 'None' '10.2.57.2/24' '10.2.57.1/24'
# node_5511-1239                                
echo "adding host edge node_5511-1239"                                
sleep 0.2                                
funCreateV 'eth_5511_1239' 'eth_1239_5511' '4' '8' '10.2.16.2/24' '10.2.16.1/24'
# node_5511-6453                                
echo "adding host edge node_5511-6453"                                
sleep 0.2                                
funCreateV 'eth_5511_6453' 'eth_6453_5511' '4' '9' '10.2.109.2/24' '10.2.109.1/24'
# node_5511-3257                                
echo "adding cluster edge node_5511-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_3257' 'eth_3257_5511' '4' 'None' '10.0.152.2/24' '10.0.152.1/24'
# node_5511-1299                                
echo "adding cluster edge node_5511-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_1299' 'eth_1299_5511' '4' 'None' '10.1.26.2/24' '10.1.26.1/24'
# node_5511-2914                                
echo "adding cluster edge node_5511-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_2914' 'eth_2914_5511' '4' 'None' '10.1.238.2/24' '10.1.238.1/24'
# node_293-13335                                
echo "adding cluster edge node_293-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_293_13335' 'eth_13335_293' '5' 'None' '10.0.96.2/24' '10.0.96.1/24'
# node_293-2914                                
echo "adding cluster edge node_293-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_293_2914' 'eth_2914_293' '5' 'None' '10.1.171.1/24' '10.1.171.2/24'
# node_293-6453                                
echo "adding host edge node_293-6453"                                
sleep 0.2                                
funCreateV 'eth_293_6453' 'eth_6453_293' '5' '9' '10.1.172.1/24' '10.1.172.2/24'
# node_293-3356                                
echo "adding cluster edge node_293-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_293_3356' 'eth_3356_293' '5' 'None' '10.0.17.2/24' '10.0.17.1/24'
# node_293-1273                                
echo "adding host edge node_293-1273"                                
sleep 0.2                                
funCreateV 'eth_293_1273' 'eth_1273_293' '5' '7' '10.1.175.1/24' '10.1.175.2/24'
# node_4837-3257                                
echo "adding cluster edge node_4837-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_3257' 'eth_3257_4837' '6' 'None' '10.0.130.2/24' '10.0.130.1/24'
# node_4837-1299                                
echo "adding cluster edge node_4837-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_1299' 'eth_1299_4837' '6' 'None' '10.0.243.2/24' '10.0.243.1/24'
# node_4837-6453                                
echo "adding host edge node_4837-6453"                                
sleep 0.2                                
funCreateV 'eth_4837_6453' 'eth_6453_4837' '6' '9' '10.2.86.2/24' '10.2.86.1/24'
# node_4837-2914                                
echo "adding cluster edge node_4837-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_2914' 'eth_2914_4837' '6' 'None' '10.1.200.2/24' '10.1.200.1/24'
# node_4837-3303                                
echo "adding cluster edge node_4837-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_3303' 'eth_3303_4837' '6' 'None' '10.1.34.2/24' '10.1.34.1/24'
# node_4837-7018                                
echo "adding cluster edge node_4837-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_7018' 'eth_7018_4837' '6' 'None' '10.0.107.2/24' '10.0.107.1/24'
# node_4837-3356                                
echo "adding cluster edge node_4837-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_3356' 'eth_3356_4837' '6' 'None' '10.0.18.2/24' '10.0.18.1/24'
# node_4837-174                                
echo "adding cluster edge node_4837-174"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_174' 'eth_174_4837' '6' 'None' '10.2.79.2/24' '10.2.79.1/24'
# node_4837-1239                                
echo "adding host edge node_4837-1239"                                
sleep 0.2                                
funCreateV 'eth_4837_1239' 'eth_1239_4837' '6' '8' '10.2.25.2/24' '10.2.25.1/24'
# node_1273-3356                                
echo "adding cluster edge node_1273-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_3356' 'eth_3356_1273' '7' 'None' '10.0.19.2/24' '10.0.19.1/24'
# node_1273-1299                                
echo "adding cluster edge node_1273-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_1299' 'eth_1299_1273' '7' 'None' '10.0.253.2/24' '10.0.253.1/24'
# node_1273-6453                                
echo "adding host edge node_1273-6453"                                
sleep 0.2                                
funCreateV 'eth_1273_6453' 'eth_6453_1273' '7' '9' '10.2.96.2/24' '10.2.96.1/24'
# node_1273-3257                                
echo "adding cluster edge node_1273-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_3257' 'eth_3257_1273' '7' 'None' '10.0.141.2/24' '10.0.141.1/24'
# node_1273-3303                                
echo "adding cluster edge node_1273-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_3303' 'eth_3303_1273' '7' 'None' '10.1.50.2/24' '10.1.50.1/24'
# node_1273-1239                                
echo "adding host edge node_1273-1239"                                
sleep 0.2                                
funCreateV 'eth_1273_1239' 'eth_1239_1273' '7' '8' '10.2.24.2/24' '10.2.24.1/24'
# node_1273-174                                
echo "adding cluster edge node_1273-174"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_174' 'eth_174_1273' '7' 'None' '10.2.73.2/24' '10.2.73.1/24'
# node_1273-2914                                
echo "adding cluster edge node_1273-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_2914' 'eth_2914_1273' '7' 'None' '10.1.224.2/24' '10.1.224.1/24'
# node_1239-13335                                
echo "adding cluster edge node_1239-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_13335' 'eth_13335_1239' '8' 'None' '10.0.101.2/24' '10.0.101.1/24'
# node_1239-6453                                
echo "adding host edge node_1239-6453"                                
sleep 0.2                                
funCreateV 'eth_1239_6453' 'eth_6453_1239' '8' '9' '10.2.17.1/24' '10.2.17.2/24'
# node_1239-7018                                
echo "adding cluster edge node_1239-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_7018' 'eth_7018_1239' '8' 'None' '10.0.108.2/24' '10.0.108.1/24'
# node_1239-3356                                
echo "adding cluster edge node_1239-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_3356' 'eth_3356_1239' '8' 'None' '10.0.20.2/24' '10.0.20.1/24'
# node_1239-2914                                
echo "adding cluster edge node_1239-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_2914' 'eth_2914_1239' '8' 'None' '10.1.205.2/24' '10.1.205.1/24'
# node_1239-174                                
echo "adding cluster edge node_1239-174"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_174' 'eth_174_1239' '8' 'None' '10.2.19.1/24' '10.2.19.2/24'
# node_1239-1299                                
echo "adding cluster edge node_1239-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_1299' 'eth_1299_1239' '8' 'None' '10.0.255.2/24' '10.0.255.1/24'
# node_1239-3257                                
echo "adding cluster edge node_1239-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_3257' 'eth_3257_1239' '8' 'None' '10.0.140.2/24' '10.0.140.1/24'
# node_6453-2914                                
echo "adding cluster edge node_6453-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_2914' 'eth_2914_6453' '9' 'None' '10.1.194.2/24' '10.1.194.1/24'
# node_6453-7018                                
echo "adding cluster edge node_6453-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_7018' 'eth_7018_6453' '9' 'None' '10.0.105.2/24' '10.0.105.1/24'
# node_6453-34224                                
echo "adding cluster edge node_6453-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_34224' 'eth_34224_6453' '9' 'None' '10.0.64.2/24' '10.0.64.1/24'
# node_6453-3303                                
echo "adding cluster edge node_6453-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_3303' 'eth_3303_6453' '9' 'None' '10.1.35.2/24' '10.1.35.1/24'
# node_6453-3356                                
echo "adding cluster edge node_6453-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_3356' 'eth_3356_6453' '9' 'None' '10.0.21.2/24' '10.0.21.1/24'
# node_6453-1299                                
echo "adding cluster edge node_6453-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_1299' 'eth_1299_6453' '9' 'None' '10.0.250.2/24' '10.0.250.1/24'
# node_6453-174                                
echo "adding cluster edge node_6453-174"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_174' 'eth_174_6453' '9' 'None' '10.2.62.2/24' '10.2.62.1/24'
# node_6453-3257                                
echo "adding cluster edge node_6453-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_3257' 'eth_3257_6453' '9' 'None' '10.0.135.2/24' '10.0.135.1/24'
# node_31133-1299                                
echo "adding cluster edge node_31133-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_1299' 'eth_1299_31133' '10' 'None' '10.0.248.2/24' '10.0.248.1/24'
# node_31133-3356                                
echo "adding cluster edge node_31133-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_3356' 'eth_3356_31133' '10' 'None' '10.0.22.2/24' '10.0.22.1/24'
# node_31133-174                                
echo "adding cluster edge node_31133-174"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_174' 'eth_174_31133' '10' 'None' '10.2.61.2/24' '10.2.61.1/24'
# node_64049-1299                                
echo "adding cluster edge node_64049-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_1299' 'eth_1299_64049' '11' 'None' '10.0.254.2/24' '10.0.254.1/24'
# node_64049-3356                                
echo "adding cluster edge node_64049-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_3356' 'eth_3356_64049' '11' 'None' '10.0.23.2/24' '10.0.23.1/24'
# node_64049-3741                                
echo "adding cluster edge node_64049-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_3741' 'eth_3741_64049' '11' 'None' '10.0.168.2/24' '10.0.168.1/24'
# node_64049-2914                                
echo "adding cluster edge node_64049-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_2914' 'eth_2914_64049' '11' 'None' '10.1.209.2/24' '10.1.209.1/24'
# node_64049-3303                                
echo "adding cluster edge node_64049-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_3303' 'eth_3303_64049' '11' 'None' '10.1.42.2/24' '10.1.42.1/24'