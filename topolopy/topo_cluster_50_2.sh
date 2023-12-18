#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("6461" "3491" "6939" "9002" "37100" "3786" "5413" "701" "4134" "132203" "4766" "12552" "57866" "16735" "33891" "9607" "55410" "2497" "9680" "4775" "55644" "16509" "18403" "4809" "4637" )
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
# node_6461-2914                                
echo "adding cluster edge node_6461-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_2914' 'eth_2914_6461' '0' 'None' '10.1.196.2/24' '10.1.196.1/24'
# node_6461-57866                                
echo "adding host edge node_6461-57866"                                
sleep 0.2                                
funCreateV 'eth_6461_57866' 'eth_57866_6461' '0' '12' '10.0.223.2/24' '10.0.223.1/24'
# node_6461-4837                                
echo "adding cluster edge node_6461-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_4837' 'eth_4837_6461' '0' 'None' '10.2.183.1/24' '10.2.183.2/24'
# node_6461-6453                                
echo "adding cluster edge node_6461-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_6453' 'eth_6453_6461' '0' 'None' '10.2.88.2/24' '10.2.88.1/24'
# node_6461-3741                                
echo "adding cluster edge node_6461-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_3741' 'eth_3741_6461' '0' 'None' '10.0.167.2/24' '10.0.167.1/24'
# node_6461-2152                                
echo "adding cluster edge node_6461-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_2152' 'eth_2152_6461' '0' 'None' '10.1.62.2/24' '10.1.62.1/24'
# node_6461-5413                                
echo "adding host edge node_6461-5413"                                
sleep 0.2                                
funCreateV 'eth_6461_5413' 'eth_5413_6461' '0' '6' '10.1.187.2/24' '10.1.187.1/24'
# node_6461-37100                                
echo "adding host edge node_6461-37100"                                
sleep 0.2                                
funCreateV 'eth_6461_37100' 'eth_37100_6461' '0' '4' '10.2.42.2/24' '10.2.42.1/24'
# node_6461-12552                                
echo "adding host edge node_6461-12552"                                
sleep 0.2                                
funCreateV 'eth_6461_12552' 'eth_12552_6461' '0' '11' '10.2.119.2/24' '10.2.119.1/24'
# node_6461-7018                                
echo "adding cluster edge node_6461-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_7018' 'eth_7018_6461' '0' 'None' '10.0.110.2/24' '10.0.110.1/24'
# node_6461-3257                                
echo "adding cluster edge node_6461-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_3257' 'eth_3257_6461' '0' 'None' '10.0.136.2/24' '10.0.136.1/24'
# node_6461-3356                                
echo "adding cluster edge node_6461-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_3356' 'eth_3356_6461' '0' 'None' '10.0.24.2/24' '10.0.24.1/24'
# node_6461-1299                                
echo "adding cluster edge node_6461-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_1299' 'eth_1299_6461' '0' 'None' '10.1.0.2/24' '10.1.0.1/24'
# node_6461-1239                                
echo "adding cluster edge node_6461-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_1239' 'eth_1239_6461' '0' 'None' '10.2.20.2/24' '10.2.20.1/24'
# node_6461-3491                                
echo "adding host edge node_6461-3491"                                
sleep 0.2                                
funCreateV 'eth_6461_3491' 'eth_3491_6461' '0' '1' '10.2.185.1/24' '10.2.185.2/24'
# node_6461-4134                                
echo "adding host edge node_6461-4134"                                
sleep 0.2                                
funCreateV 'eth_6461_4134' 'eth_4134_6461' '0' '8' '10.2.187.1/24' '10.2.187.2/24'
# node_6461-132203                                
echo "adding host edge node_6461-132203"                                
sleep 0.2                                
funCreateV 'eth_6461_132203' 'eth_132203_6461' '0' '9' '10.2.188.1/24' '10.2.188.2/24'
# node_6461-1273                                
echo "adding cluster edge node_6461-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_1273' 'eth_1273_6461' '0' 'None' '10.2.191.1/24' '10.2.191.2/24'
# node_6461-9002                                
echo "adding host edge node_6461-9002"                                
sleep 0.2                                
funCreateV 'eth_6461_9002' 'eth_9002_6461' '0' '3' '10.2.192.1/24' '10.2.192.2/24'
# node_6461-174                                
echo "adding cluster edge node_6461-174"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_174' 'eth_174_6461' '0' 'None' '10.2.75.2/24' '10.2.75.1/24'
# node_6461-9680                                
echo "adding host edge node_6461-9680"                                
sleep 0.2                                
funCreateV 'eth_6461_9680' 'eth_9680_6461' '0' '18' '10.2.193.1/24' '10.2.193.2/24'
# node_6461-6939                                
echo "adding host edge node_6461-6939"                                
sleep 0.2                                
funCreateV 'eth_6461_6939' 'eth_6939_6461' '0' '2' '10.1.118.2/24' '10.1.118.1/24'
# node_6461-3303                                
echo "adding cluster edge node_6461-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_3303' 'eth_3303_6461' '0' 'None' '10.1.53.2/24' '10.1.53.1/24'
# node_6461-2497                                
echo "adding host edge node_6461-2497"                                
sleep 0.2                                
funCreateV 'eth_6461_2497' 'eth_2497_6461' '0' '17' '10.1.163.2/24' '10.1.163.1/24'
# node_6461-5511                                
echo "adding cluster edge node_6461-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_5511' 'eth_5511_6461' '0' 'None' '10.2.195.1/24' '10.2.195.2/24'
# node_6461-4637                                
echo "adding host edge node_6461-4637"                                
sleep 0.2                                
funCreateV 'eth_6461_4637' 'eth_4637_6461' '0' '24' '10.2.147.2/24' '10.2.147.1/24'
# node_3491-3257                                
echo "adding cluster edge node_3491-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_3257' 'eth_3257_3491' '1' 'None' '10.0.131.2/24' '10.0.131.1/24'
# node_3491-2497                                
echo "adding host edge node_3491-2497"                                
sleep 0.2                                
funCreateV 'eth_3491_2497' 'eth_2497_3491' '1' '17' '10.1.147.2/24' '10.1.147.1/24'
# node_3491-174                                
echo "adding cluster edge node_3491-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_174' 'eth_174_3491' '1' 'None' '10.2.58.2/24' '10.2.58.1/24'
# node_3491-2914                                
echo "adding cluster edge node_3491-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_2914' 'eth_2914_3491' '1' 'None' '10.1.207.2/24' '10.1.207.1/24'
# node_3491-6939                                
echo "adding host edge node_3491-6939"                                
sleep 0.2                                
funCreateV 'eth_3491_6939' 'eth_6939_3491' '1' '2' '10.1.93.2/24' '10.1.93.1/24'
# node_3491-7018                                
echo "adding cluster edge node_3491-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_7018' 'eth_7018_3491' '1' 'None' '10.0.111.2/24' '10.0.111.1/24'
# node_3491-3356                                
echo "adding cluster edge node_3491-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_3356' 'eth_3356_3491' '1' 'None' '10.0.25.2/24' '10.0.25.1/24'
# node_3491-1299                                
echo "adding cluster edge node_3491-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_1299' 'eth_1299_3491' '1' 'None' '10.1.1.2/24' '10.1.1.1/24'
# node_3491-1239                                
echo "adding cluster edge node_3491-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_1239' 'eth_1239_3491' '1' 'None' '10.2.21.2/24' '10.2.21.1/24'
# node_3491-3303                                
echo "adding cluster edge node_3491-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_3303' 'eth_3303_3491' '1' 'None' '10.1.40.2/24' '10.1.40.1/24'
# node_3491-293                                
echo "adding cluster edge node_3491-293"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_293' 'eth_293_3491' '1' 'None' '10.1.173.2/24' '10.1.173.1/24'
# node_3491-38040                                
echo "adding cluster edge node_3491-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_38040' 'eth_38040_3491' '1' 'None' '10.2.220.2/24' '10.2.220.1/24'
# node_3491-132203                                
echo "adding host edge node_3491-132203"                                
sleep 0.2                                
funCreateV 'eth_3491_132203' 'eth_132203_3491' '1' '9' '10.3.47.1/24' '10.3.47.2/24'
# node_3491-6453                                
echo "adding cluster edge node_3491-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_6453' 'eth_6453_3491' '1' 'None' '10.2.102.2/24' '10.2.102.1/24'
# node_3491-5413                                
echo "adding host edge node_3491-5413"                                
sleep 0.2                                
funCreateV 'eth_3491_5413' 'eth_5413_3491' '1' '6' '10.1.191.2/24' '10.1.191.1/24'
# node_3491-55644                                
echo "adding host edge node_3491-55644"                                
sleep 0.2                                
funCreateV 'eth_3491_55644' 'eth_55644_3491' '1' '20' '10.3.51.1/24' '10.3.51.2/24'
# node_3491-18403                                
echo "adding host edge node_3491-18403"                                
sleep 0.2                                
funCreateV 'eth_3491_18403' 'eth_18403_3491' '1' '22' '10.3.53.1/24' '10.3.53.2/24'
# node_3491-6762                                
echo "adding cluster edge node_3491-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_6762' 'eth_6762_3491' '1' 'None' '10.2.174.2/24' '10.2.174.1/24'
# node_3491-4809                                
echo "adding host edge node_3491-4809"                                
sleep 0.2                                
funCreateV 'eth_3491_4809' 'eth_4809_3491' '1' '23' '10.3.56.1/24' '10.3.56.2/24'
# node_6939-13335                                
echo "adding cluster edge node_6939-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_13335' 'eth_13335_6939' '2' 'None' '10.0.94.2/24' '10.0.94.1/24'
# node_6939-37100                                
echo "adding host edge node_6939-37100"                                
sleep 0.2                                
funCreateV 'eth_6939_37100' 'eth_37100_6939' '2' '4' '10.1.75.1/24' '10.1.75.2/24'
# node_6939-5413                                
echo "adding host edge node_6939-5413"                                
sleep 0.2                                
funCreateV 'eth_6939_5413' 'eth_5413_6939' '2' '6' '10.1.78.1/24' '10.1.78.2/24'
# node_6939-3741                                
echo "adding cluster edge node_6939-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_3741' 'eth_3741_6939' '2' 'None' '10.0.160.2/24' '10.0.160.1/24'
# node_6939-34224                                
echo "adding cluster edge node_6939-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_34224' 'eth_34224_6939' '2' 'None' '10.0.60.2/24' '10.0.60.1/24'
# node_6939-293                                
echo "adding cluster edge node_6939-293"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_293' 'eth_293_6939' '2' 'None' '10.1.81.1/24' '10.1.81.2/24'
# node_6939-3303                                
echo "adding cluster edge node_6939-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_3303' 'eth_3303_6939' '2' 'None' '10.1.29.2/24' '10.1.29.1/24'
# node_6939-2152                                
echo "adding cluster edge node_6939-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_2152' 'eth_2152_6939' '2' 'None' '10.1.58.2/24' '10.1.58.1/24'
# node_6939-2519                                
echo "adding cluster edge node_6939-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_2519' 'eth_2519_6939' '2' 'None' '10.1.83.1/24' '10.1.83.2/24'
# node_6939-38040                                
echo "adding cluster edge node_6939-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_38040' 'eth_38040_6939' '2' 'None' '10.1.86.1/24' '10.1.86.2/24'
# node_6939-5511                                
echo "adding cluster edge node_6939-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_5511' 'eth_5511_6939' '2' 'None' '10.1.88.1/24' '10.1.88.2/24'
# node_6939-1239                                
echo "adding cluster edge node_6939-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_1239' 'eth_1239_6939' '2' 'None' '10.1.90.1/24' '10.1.90.2/24'
# node_6939-1299                                
echo "adding cluster edge node_6939-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_1299' 'eth_1299_6939' '2' 'None' '10.0.251.2/24' '10.0.251.1/24'
# node_6939-64049                                
echo "adding cluster edge node_6939-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_64049' 'eth_64049_6939' '2' 'None' '10.1.92.1/24' '10.1.92.2/24'
# node_6939-2497                                
echo "adding host edge node_6939-2497"                                
sleep 0.2                                
funCreateV 'eth_6939_2497' 'eth_2497_6939' '2' '17' '10.1.95.1/24' '10.1.95.2/24'
# node_6939-3356                                
echo "adding cluster edge node_6939-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_3356' 'eth_3356_6939' '2' 'None' '10.0.26.2/24' '10.0.26.1/24'
# node_6939-3786                                
echo "adding host edge node_6939-3786"                                
sleep 0.2                                
funCreateV 'eth_6939_3786' 'eth_3786_6939' '2' '5' '10.1.96.1/24' '10.1.96.2/24'
# node_6939-4134                                
echo "adding host edge node_6939-4134"                                
sleep 0.2                                
funCreateV 'eth_6939_4134' 'eth_4134_6939' '2' '8' '10.1.99.1/24' '10.1.99.2/24'
# node_6939-132203                                
echo "adding host edge node_6939-132203"                                
sleep 0.2                                
funCreateV 'eth_6939_132203' 'eth_132203_6939' '2' '9' '10.1.100.1/24' '10.1.100.2/24'
# node_6939-4766                                
echo "adding host edge node_6939-4766"                                
sleep 0.2                                
funCreateV 'eth_6939_4766' 'eth_4766_6939' '2' '10' '10.1.101.1/24' '10.1.101.2/24'
# node_6939-12552                                
echo "adding host edge node_6939-12552"                                
sleep 0.2                                
funCreateV 'eth_6939_12552' 'eth_12552_6939' '2' '11' '10.1.102.1/24' '10.1.102.2/24'
# node_6939-7018                                
echo "adding cluster edge node_6939-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_7018' 'eth_7018_6939' '2' 'None' '10.0.114.2/24' '10.0.114.1/24'
# node_6939-1273                                
echo "adding cluster edge node_6939-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_1273' 'eth_1273_6939' '2' 'None' '10.1.106.1/24' '10.1.106.2/24'
# node_6939-4837                                
echo "adding cluster edge node_6939-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_4837' 'eth_4837_6939' '2' 'None' '10.1.108.1/24' '10.1.108.2/24'
# node_6939-701                                
echo "adding host edge node_6939-701"                                
sleep 0.2                                
funCreateV 'eth_6939_701' 'eth_701_6939' '2' '7' '10.1.109.1/24' '10.1.109.2/24'
# node_6939-9002                                
echo "adding host edge node_6939-9002"                                
sleep 0.2                                
funCreateV 'eth_6939_9002' 'eth_9002_6939' '2' '3' '10.1.111.1/24' '10.1.111.2/24'
# node_6939-9680                                
echo "adding host edge node_6939-9680"                                
sleep 0.2                                
funCreateV 'eth_6939_9680' 'eth_9680_6939' '2' '18' '10.1.114.1/24' '10.1.114.2/24'
# node_6939-4775                                
echo "adding host edge node_6939-4775"                                
sleep 0.2                                
funCreateV 'eth_6939_4775' 'eth_4775_6939' '2' '19' '10.1.117.1/24' '10.1.117.2/24'
# node_6939-16509                                
echo "adding host edge node_6939-16509"                                
sleep 0.2                                
funCreateV 'eth_6939_16509' 'eth_16509_6939' '2' '21' '10.1.119.1/24' '10.1.119.2/24'
# node_6939-18403                                
echo "adding host edge node_6939-18403"                                
sleep 0.2                                
funCreateV 'eth_6939_18403' 'eth_18403_6939' '2' '22' '10.1.123.1/24' '10.1.123.2/24'
# node_6939-4809                                
echo "adding host edge node_6939-4809"                                
sleep 0.2                                
funCreateV 'eth_6939_4809' 'eth_4809_6939' '2' '23' '10.1.125.1/24' '10.1.125.2/24'
# node_6939-4637                                
echo "adding host edge node_6939-4637"                                
sleep 0.2                                
funCreateV 'eth_6939_4637' 'eth_4637_6939' '2' '24' '10.1.128.1/24' '10.1.128.2/24'
# node_6939-6762                                
echo "adding cluster edge node_6939-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_6762' 'eth_6762_6939' '2' 'None' '10.1.131.1/24' '10.1.131.2/24'
# node_9002-3741                                
echo "adding cluster edge node_9002-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_3741' 'eth_3741_9002' '3' 'None' '10.0.164.2/24' '10.0.164.1/24'
# node_9002-38040                                
echo "adding cluster edge node_9002-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_38040' 'eth_38040_9002' '3' 'None' '10.2.219.2/24' '10.2.219.1/24'
# node_9002-3356                                
echo "adding cluster edge node_9002-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_3356' 'eth_3356_9002' '3' 'None' '10.0.27.2/24' '10.0.27.1/24'
# node_9002-57866                                
echo "adding host edge node_9002-57866"                                
sleep 0.2                                
funCreateV 'eth_9002_57866' 'eth_57866_9002' '3' '12' '10.0.225.2/24' '10.0.225.1/24'
# node_9002-12552                                
echo "adding host edge node_9002-12552"                                
sleep 0.2                                
funCreateV 'eth_9002_12552' 'eth_12552_9002' '3' '11' '10.2.124.2/24' '10.2.124.1/24'
# node_9002-34224                                
echo "adding cluster edge node_9002-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_34224' 'eth_34224_9002' '3' 'None' '10.0.71.2/24' '10.0.71.1/24'
# node_9002-5413                                
echo "adding host edge node_9002-5413"                                
sleep 0.2                                
funCreateV 'eth_9002_5413' 'eth_5413_9002' '3' '6' '10.1.190.2/24' '10.1.190.1/24'
# node_9002-6453                                
echo "adding cluster edge node_9002-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_6453' 'eth_6453_9002' '3' 'None' '10.2.101.2/24' '10.2.101.1/24'
# node_9002-3303                                
echo "adding cluster edge node_9002-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_3303' 'eth_3303_9002' '3' 'None' '10.1.52.2/24' '10.1.52.1/24'
# node_9002-293                                
echo "adding cluster edge node_9002-293"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_293' 'eth_293_9002' '3' 'None' '10.1.177.2/24' '10.1.177.1/24'
# node_9002-1299                                
echo "adding cluster edge node_9002-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_1299' 'eth_1299_9002' '3' 'None' '10.1.12.2/24' '10.1.12.1/24'
# node_37100-2497                                
echo "adding host edge node_37100-2497"                                
sleep 0.2                                
funCreateV 'eth_37100_2497' 'eth_2497_37100' '4' '17' '10.1.136.2/24' '10.1.136.1/24'
# node_37100-3257                                
echo "adding cluster edge node_37100-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_3257' 'eth_3257_37100' '4' 'None' '10.0.129.2/24' '10.0.129.1/24'
# node_37100-6453                                
echo "adding cluster edge node_37100-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_6453' 'eth_6453_37100' '4' 'None' '10.2.38.1/24' '10.2.38.2/24'
# node_37100-2914                                
echo "adding cluster edge node_37100-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_2914' 'eth_2914_37100' '4' 'None' '10.1.206.2/24' '10.1.206.1/24'
# node_37100-174                                
echo "adding cluster edge node_37100-174"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_174' 'eth_174_37100' '4' 'None' '10.2.40.1/24' '10.2.40.2/24'
# node_37100-6762                                
echo "adding cluster edge node_37100-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_6762' 'eth_6762_37100' '4' 'None' '10.2.41.1/24' '10.2.41.2/24'
# node_37100-64049                                
echo "adding cluster edge node_37100-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_64049' 'eth_64049_37100' '4' 'None' '10.2.43.1/24' '10.2.43.2/24'
# node_37100-3356                                
echo "adding cluster edge node_37100-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_3356' 'eth_3356_37100' '4' 'None' '10.0.28.2/24' '10.0.28.1/24'
# node_37100-1299                                
echo "adding cluster edge node_37100-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_1299' 'eth_1299_37100' '4' 'None' '10.1.3.2/24' '10.1.3.1/24'
# node_37100-132203                                
echo "adding host edge node_37100-132203"                                
sleep 0.2                                
funCreateV 'eth_37100_132203' 'eth_132203_37100' '4' '9' '10.2.45.1/24' '10.2.45.2/24'
# node_37100-4775                                
echo "adding host edge node_37100-4775"                                
sleep 0.2                                
funCreateV 'eth_37100_4775' 'eth_4775_37100' '4' '19' '10.2.50.1/24' '10.2.50.2/24'
# node_3786-3356                                
echo "adding cluster edge node_3786-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_3356' 'eth_3356_3786' '5' 'None' '10.0.29.2/24' '10.0.29.1/24'
# node_3786-2914                                
echo "adding cluster edge node_3786-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_2914' 'eth_2914_3786' '5' 'None' '10.1.212.2/24' '10.1.212.1/24'
# node_3786-31133                                
echo "adding cluster edge node_3786-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_31133' 'eth_31133_3786' '5' 'None' '10.2.148.2/24' '10.2.148.1/24'
# node_3786-3303                                
echo "adding cluster edge node_3786-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_3303' 'eth_3303_3786' '5' 'None' '10.1.43.2/24' '10.1.43.1/24'
# node_3786-2497                                
echo "adding host edge node_3786-2497"                                
sleep 0.2                                
funCreateV 'eth_3786_2497' 'eth_2497_3786' '5' '17' '10.1.151.2/24' '10.1.151.1/24'
# node_3786-2152                                
echo "adding cluster edge node_3786-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_2152' 'eth_2152_3786' '5' 'None' '10.1.64.2/24' '10.1.64.1/24'
# node_3786-1239                                
echo "adding cluster edge node_3786-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_1239' 'eth_1239_3786' '5' 'None' '10.2.22.2/24' '10.2.22.1/24'
# node_3786-6453                                
echo "adding cluster edge node_3786-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_6453' 'eth_6453_3786' '5' 'None' '10.2.111.2/24' '10.2.111.1/24'
# node_3786-174                                
echo "adding cluster edge node_3786-174"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_174' 'eth_174_3786' '5' 'None' '10.2.83.2/24' '10.2.83.1/24'
# node_3786-4637                                
echo "adding host edge node_3786-4637"                                
sleep 0.2                                
funCreateV 'eth_3786_4637' 'eth_4637_3786' '5' '24' '10.2.146.2/24' '10.2.146.1/24'
# node_5413-13335                                
echo "adding cluster edge node_5413-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_5413_13335' 'eth_13335_5413' '6' 'None' '10.0.97.2/24' '10.0.97.1/24'
# node_5413-4637                                
echo "adding host edge node_5413-4637"                                
sleep 0.2                                
funCreateV 'eth_5413_4637' 'eth_4637_5413' '6' '24' '10.1.184.1/24' '10.1.184.2/24'
# node_5413-1299                                
echo "adding cluster edge node_5413-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_5413_1299' 'eth_1299_5413' '6' 'None' '10.0.244.2/24' '10.0.244.1/24'
# node_5413-3356                                
echo "adding cluster edge node_5413-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_5413_3356' 'eth_3356_5413' '6' 'None' '10.0.30.2/24' '10.0.30.1/24'
# node_5413-2914                                
echo "adding cluster edge node_5413-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_5413_2914' 'eth_2914_5413' '6' 'None' '10.1.192.1/24' '10.1.192.2/24'
# node_701-3356                                
echo "adding cluster edge node_701-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_701_3356' 'eth_3356_701' '7' 'None' '10.0.31.2/24' '10.0.31.1/24'
# node_701-7018                                
echo "adding cluster edge node_701-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_701_7018' 'eth_7018_701' '7' 'None' '10.0.113.2/24' '10.0.113.1/24'
# node_701-1239                                
echo "adding cluster edge node_701-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_701_1239' 'eth_1239_701' '7' 'None' '10.2.26.2/24' '10.2.26.1/24'
# node_701-4837                                
echo "adding cluster edge node_701-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_701_4837' 'eth_4837_701' '7' 'None' '10.3.14.2/24' '10.3.14.1/24'
# node_701-9680                                
echo "adding host edge node_701-9680"                                
sleep 0.2                                
funCreateV 'eth_701_9680' 'eth_9680_701' '7' '18' '10.3.168.1/24' '10.3.168.2/24'
# node_4134-3741                                
echo "adding cluster edge node_4134-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_3741' 'eth_3741_4134' '8' 'None' '10.0.165.2/24' '10.0.165.1/24'
# node_4134-3257                                
echo "adding cluster edge node_4134-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_3257' 'eth_3257_4134' '8' 'None' '10.0.137.2/24' '10.0.137.1/24'
# node_4134-7018                                
echo "adding cluster edge node_4134-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_7018' 'eth_7018_4134' '8' 'None' '10.0.112.2/24' '10.0.112.1/24'
# node_4134-3356                                
echo "adding cluster edge node_4134-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_3356' 'eth_3356_4134' '8' 'None' '10.0.32.2/24' '10.0.32.1/24'
# node_4134-2914                                
echo "adding cluster edge node_4134-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_2914' 'eth_2914_4134' '8' 'None' '10.1.215.2/24' '10.1.215.1/24'
# node_4134-1299                                
echo "adding cluster edge node_4134-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_1299' 'eth_1299_4134' '8' 'None' '10.1.5.2/24' '10.1.5.1/24'
# node_4134-174                                
echo "adding cluster edge node_4134-174"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_174' 'eth_174_4134' '8' 'None' '10.2.67.2/24' '10.2.67.1/24'
# node_4134-31133                                
echo "adding cluster edge node_4134-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_31133' 'eth_31133_4134' '8' 'None' '10.2.149.2/24' '10.2.149.1/24'
# node_4134-3303                                
echo "adding cluster edge node_4134-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_3303' 'eth_3303_4134' '8' 'None' '10.1.45.2/24' '10.1.45.1/24'
# node_4134-2497                                
echo "adding host edge node_4134-2497"                                
sleep 0.2                                
funCreateV 'eth_4134_2497' 'eth_2497_4134' '8' '17' '10.1.153.2/24' '10.1.153.1/24'
# node_4134-6453                                
echo "adding cluster edge node_4134-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_6453' 'eth_6453_4134' '8' 'None' '10.2.99.2/24' '10.2.99.1/24'
# node_4134-4837                                
echo "adding cluster edge node_4134-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_4837' 'eth_4837_4134' '8' 'None' '10.3.12.2/24' '10.3.12.1/24'
# node_4134-6762                                
echo "adding cluster edge node_4134-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_6762' 'eth_6762_4134' '8' 'None' '10.2.175.2/24' '10.2.175.1/24'
# node_4134-4809                                
echo "adding host edge node_4134-4809"                                
sleep 0.2                                
funCreateV 'eth_4134_4809' 'eth_4809_4134' '8' '23' '10.3.81.1/24' '10.3.81.2/24'
# node_132203-12552                                
echo "adding host edge node_132203-12552"                                
sleep 0.2                                
funCreateV 'eth_132203_12552' 'eth_12552_132203' '9' '11' '10.2.121.2/24' '10.2.121.1/24'
# node_132203-2152                                
echo "adding cluster edge node_132203-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_2152' 'eth_2152_132203' '9' 'None' '10.1.66.2/24' '10.1.66.1/24'
# node_132203-3303                                
echo "adding cluster edge node_132203-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_3303' 'eth_3303_132203' '9' 'None' '10.1.46.2/24' '10.1.46.1/24'
# node_132203-4766                                
echo "adding host edge node_132203-4766"                                
sleep 0.2                                
funCreateV 'eth_132203_4766' 'eth_4766_132203' '9' '10' '10.3.0.2/24' '10.3.0.1/24'
# node_132203-3356                                
echo "adding cluster edge node_132203-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_3356' 'eth_3356_132203' '9' 'None' '10.0.33.2/24' '10.0.33.1/24'
# node_132203-34224                                
echo "adding cluster edge node_132203-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_34224' 'eth_34224_132203' '9' 'None' '10.0.68.2/24' '10.0.68.1/24'
# node_132203-1299                                
echo "adding cluster edge node_132203-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_1299' 'eth_1299_132203' '9' 'None' '10.1.6.2/24' '10.1.6.1/24'
# node_132203-2914                                
echo "adding cluster edge node_132203-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_132203_2914' 'eth_2914_132203' '9' 'None' '10.1.216.2/24' '10.1.216.1/24'
# node_4766-1239                                
echo "adding cluster edge node_4766-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_1239' 'eth_1239_4766' '10' 'None' '10.2.15.2/24' '10.2.15.1/24'
# node_4766-1299                                
echo "adding cluster edge node_4766-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_1299' 'eth_1299_4766' '10' 'None' '10.1.7.2/24' '10.1.7.1/24'
# node_4766-3257                                
echo "adding cluster edge node_4766-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_3257' 'eth_3257_4766' '10' 'None' '10.0.138.2/24' '10.0.138.1/24'
# node_4766-3356                                
echo "adding cluster edge node_4766-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_3356' 'eth_3356_4766' '10' 'None' '10.0.34.2/24' '10.0.34.1/24'
# node_4766-2152                                
echo "adding cluster edge node_4766-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_2152' 'eth_2152_4766' '10' 'None' '10.1.67.2/24' '10.1.67.1/24'
# node_4766-2914                                
echo "adding cluster edge node_4766-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_2914' 'eth_2914_4766' '10' 'None' '10.1.217.2/24' '10.1.217.1/24'
# node_4766-3303                                
echo "adding cluster edge node_4766-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_3303' 'eth_3303_4766' '10' 'None' '10.1.47.2/24' '10.1.47.1/24'
# node_4766-2497                                
echo "adding host edge node_4766-2497"                                
sleep 0.2                                
funCreateV 'eth_4766_2497' 'eth_2497_4766' '10' '17' '10.1.154.2/24' '10.1.154.1/24'
# node_4766-31133                                
echo "adding cluster edge node_4766-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_31133' 'eth_31133_4766' '10' 'None' '10.2.150.2/24' '10.2.150.1/24'
# node_4766-4775                                
echo "adding host edge node_4766-4775"                                
sleep 0.2                                
funCreateV 'eth_4766_4775' 'eth_4775_4766' '10' '19' '10.2.253.1/24' '10.2.253.2/24'
# node_12552-4637                                
echo "adding host edge node_12552-4637"                                
sleep 0.2                                
funCreateV 'eth_12552_4637' 'eth_4637_12552' '11' '24' '10.2.114.1/24' '10.2.114.2/24'
# node_12552-64049                                
echo "adding cluster edge node_12552-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_12552_64049' 'eth_64049_12552' '11' 'None' '10.2.118.1/24' '10.2.118.2/24'
# node_12552-3356                                
echo "adding cluster edge node_12552-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_12552_3356' 'eth_3356_12552' '11' 'None' '10.0.35.2/24' '10.0.35.1/24'
# node_12552-18403                                
echo "adding host edge node_12552-18403"                                
sleep 0.2                                
funCreateV 'eth_12552_18403' 'eth_18403_12552' '11' '22' '10.2.127.1/24' '10.2.127.2/24'
# node_12552-38040                                
echo "adding cluster edge node_12552-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_12552_38040' 'eth_38040_12552' '11' 'None' '10.2.132.1/24' '10.2.132.2/24'
# node_57866-13335                                
echo "adding cluster edge node_57866-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_57866_13335' 'eth_13335_57866' '12' 'None' '10.0.90.2/24' '10.0.90.1/24'
# node_57866-1299                                
echo "adding cluster edge node_57866-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_57866_1299' 'eth_1299_57866' '12' 'None' '10.0.220.1/24' '10.0.220.2/24'
# node_57866-2914                                
echo "adding cluster edge node_57866-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_57866_2914' 'eth_2914_57866' '12' 'None' '10.0.221.1/24' '10.0.221.2/24'
# node_57866-6453                                
echo "adding cluster edge node_57866-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_57866_6453' 'eth_6453_57866' '12' 'None' '10.0.224.1/24' '10.0.224.2/24'
# node_57866-3356                                
echo "adding cluster edge node_57866-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_57866_3356' 'eth_3356_57866' '12' 'None' '10.0.36.2/24' '10.0.36.1/24'
# node_16735-3356                                
echo "adding cluster edge node_16735-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_16735_3356' 'eth_3356_16735' '13' 'None' '10.0.37.2/24' '10.0.37.1/24'
# node_33891-3356                                
echo "adding cluster edge node_33891-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_33891_3356' 'eth_3356_33891' '14' 'None' '10.0.38.2/24' '10.0.38.1/24'
# node_9607-3356                                
echo "adding cluster edge node_9607-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_9607_3356' 'eth_3356_9607' '15' 'None' '10.0.39.2/24' '10.0.39.1/24'
# node_9607-4637                                
echo "adding host edge node_9607-4637"                                
sleep 0.2                                
funCreateV 'eth_9607_4637' 'eth_4637_9607' '15' '24' '10.2.138.2/24' '10.2.138.1/24'
# node_55410-1273                                
echo "adding cluster edge node_55410-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_1273' 'eth_1273_55410' '16' 'None' '10.3.84.2/24' '10.3.84.1/24'
# node_55410-3356                                
echo "adding cluster edge node_55410-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_3356' 'eth_3356_55410' '16' 'None' '10.0.40.2/24' '10.0.40.1/24'
# node_55410-55644                                
echo "adding host edge node_55410-55644"                                
sleep 0.2                                
funCreateV 'eth_55410_55644' 'eth_55644_55410' '16' '20' '10.3.179.1/24' '10.3.179.2/24'
# node_2497-13335                                
echo "adding cluster edge node_2497-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_13335' 'eth_13335_2497' '17' 'None' '10.0.95.2/24' '10.0.95.1/24'
# node_2497-6453                                
echo "adding cluster edge node_2497-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_6453' 'eth_6453_2497' '17' 'None' '10.1.135.1/24' '10.1.135.2/24'
# node_2497-2519                                
echo "adding cluster edge node_2497-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_2519' 'eth_2519_2497' '17' 'None' '10.1.137.1/24' '10.1.137.2/24'
# node_2497-2914                                
echo "adding cluster edge node_2497-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_2914' 'eth_2914_2497' '17' 'None' '10.1.140.1/24' '10.1.140.2/24'
# node_2497-7018                                
echo "adding cluster edge node_2497-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_7018' 'eth_7018_2497' '17' 'None' '10.0.104.2/24' '10.0.104.1/24'
# node_2497-3257                                
echo "adding cluster edge node_2497-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_3257' 'eth_3257_2497' '17' 'None' '10.0.127.2/24' '10.0.127.1/24'
# node_2497-1299                                
echo "adding cluster edge node_2497-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_1299' 'eth_1299_2497' '17' 'None' '10.0.240.2/24' '10.0.240.1/24'
# node_2497-293                                
echo "adding cluster edge node_2497-293"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_293' 'eth_293_2497' '17' 'None' '10.1.144.1/24' '10.1.144.2/24'
# node_2497-3303                                
echo "adding cluster edge node_2497-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_3303' 'eth_3303_2497' '17' 'None' '10.1.31.2/24' '10.1.31.1/24'
# node_2497-38040                                
echo "adding cluster edge node_2497-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_38040' 'eth_38040_2497' '17' 'None' '10.1.145.1/24' '10.1.145.2/24'
# node_2497-4837                                
echo "adding cluster edge node_2497-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_4837' 'eth_4837_2497' '17' 'None' '10.1.146.1/24' '10.1.146.2/24'
# node_2497-174                                
echo "adding cluster edge node_2497-174"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_174' 'eth_174_2497' '17' 'None' '10.1.155.1/24' '10.1.155.2/24'
# node_2497-1273                                
echo "adding cluster edge node_2497-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_1273' 'eth_1273_2497' '17' 'None' '10.1.158.1/24' '10.1.158.2/24'
# node_2497-3356                                
echo "adding cluster edge node_2497-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_3356' 'eth_3356_2497' '17' 'None' '10.0.41.2/24' '10.0.41.1/24'
# node_2497-4775                                
echo "adding host edge node_2497-4775"                                
sleep 0.2                                
funCreateV 'eth_2497_4775' 'eth_4775_2497' '17' '19' '10.1.162.1/24' '10.1.162.2/24'
# node_2497-16509                                
echo "adding host edge node_2497-16509"                                
sleep 0.2                                
funCreateV 'eth_2497_16509' 'eth_16509_2497' '17' '21' '10.1.164.1/24' '10.1.164.2/24'
# node_2497-4637                                
echo "adding host edge node_2497-4637"                                
sleep 0.2                                
funCreateV 'eth_2497_4637' 'eth_4637_2497' '17' '24' '10.1.168.1/24' '10.1.168.2/24'
# node_2497-5511                                
echo "adding cluster edge node_2497-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_5511' 'eth_5511_2497' '17' 'None' '10.1.169.1/24' '10.1.169.2/24'
# node_9680-6762                                
echo "adding cluster edge node_9680-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_6762' 'eth_6762_9680' '18' 'None' '10.2.171.2/24' '10.2.171.1/24'
# node_9680-7018                                
echo "adding cluster edge node_9680-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_7018' 'eth_7018_9680' '18' 'None' '10.0.115.2/24' '10.0.115.1/24'
# node_9680-1299                                
echo "adding cluster edge node_9680-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_1299' 'eth_1299_9680' '18' 'None' '10.1.13.2/24' '10.1.13.1/24'
# node_9680-2152                                
echo "adding cluster edge node_9680-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_2152' 'eth_2152_9680' '18' 'None' '10.1.68.2/24' '10.1.68.1/24'
# node_9680-174                                
echo "adding cluster edge node_9680-174"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_174' 'eth_174_9680' '18' 'None' '10.2.76.2/24' '10.2.76.1/24'
# node_9680-3356                                
echo "adding cluster edge node_9680-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_9680_3356' 'eth_3356_9680' '18' 'None' '10.0.42.2/24' '10.0.42.1/24'
# node_4775-7018                                
echo "adding cluster edge node_4775-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_7018' 'eth_7018_4775' '19' 'None' '10.0.116.2/24' '10.0.116.1/24'
# node_4775-1299                                
echo "adding cluster edge node_4775-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_1299' 'eth_1299_4775' '19' 'None' '10.1.14.2/24' '10.1.14.1/24'
# node_4775-3549                                
echo "adding cluster edge node_4775-3549"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_3549' 'eth_3549_4775' '19' 'None' '10.0.159.2/24' '10.0.159.1/24'
# node_4775-34224                                
echo "adding cluster edge node_4775-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_34224' 'eth_34224_4775' '19' 'None' '10.0.74.2/24' '10.0.74.1/24'
# node_4775-3356                                
echo "adding cluster edge node_4775-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_3356' 'eth_3356_4775' '19' 'None' '10.0.43.2/24' '10.0.43.1/24'
# node_4775-1239                                
echo "adding cluster edge node_4775-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_1239' 'eth_1239_4775' '19' 'None' '10.2.29.2/24' '10.2.29.1/24'
# node_4775-6453                                
echo "adding cluster edge node_4775-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_6453' 'eth_6453_4775' '19' 'None' '10.2.104.2/24' '10.2.104.1/24'
# node_4775-2914                                
echo "adding cluster edge node_4775-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_2914' 'eth_2914_4775' '19' 'None' '10.1.229.2/24' '10.1.229.1/24'
# node_4775-4637                                
echo "adding host edge node_4775-4637"                                
sleep 0.2                                
funCreateV 'eth_4775_4637' 'eth_4637_4775' '19' '24' '10.2.140.2/24' '10.2.140.1/24'
# node_55644-3356                                
echo "adding cluster edge node_55644-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_55644_3356' 'eth_3356_55644' '20' 'None' '10.0.44.2/24' '10.0.44.1/24'
# node_55644-174                                
echo "adding cluster edge node_55644-174"                                
sleep 0.2                                
funCreateClusterV 'eth_55644_174' 'eth_174_55644' '20' 'None' '10.2.77.2/24' '10.2.77.1/24'
# node_55644-1273                                
echo "adding cluster edge node_55644-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_55644_1273' 'eth_1273_55644' '20' 'None' '10.3.87.2/24' '10.3.87.1/24'
# node_16509-3257                                
echo "adding cluster edge node_16509-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_3257' 'eth_3257_16509' '21' 'None' '10.0.144.2/24' '10.0.144.1/24'
# node_16509-7018                                
echo "adding cluster edge node_16509-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_7018' 'eth_7018_16509' '21' 'None' '10.0.117.2/24' '10.0.117.1/24'
# node_16509-3356                                
echo "adding cluster edge node_16509-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_3356' 'eth_3356_16509' '21' 'None' '10.0.45.2/24' '10.0.45.1/24'
# node_16509-1299                                
echo "adding cluster edge node_16509-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_1299' 'eth_1299_16509' '21' 'None' '10.1.15.2/24' '10.1.15.1/24'
# node_16509-2914                                
echo "adding cluster edge node_16509-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_2914' 'eth_2914_16509' '21' 'None' '10.1.230.2/24' '10.1.230.1/24'
# node_16509-6453                                
echo "adding cluster edge node_16509-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_6453' 'eth_6453_16509' '21' 'None' '10.2.105.2/24' '10.2.105.1/24'
# node_16509-174                                
echo "adding cluster edge node_16509-174"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_174' 'eth_174_16509' '21' 'None' '10.2.78.2/24' '10.2.78.1/24'
# node_16509-1239                                
echo "adding cluster edge node_16509-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_1239' 'eth_1239_16509' '21' 'None' '10.2.30.2/24' '10.2.30.1/24'
# node_16509-2152                                
echo "adding cluster edge node_16509-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_2152' 'eth_2152_16509' '21' 'None' '10.1.69.2/24' '10.1.69.1/24'
# node_18403-2914                                
echo "adding cluster edge node_18403-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_2914' 'eth_2914_18403' '22' 'None' '10.1.234.2/24' '10.1.234.1/24'
# node_18403-34224                                
echo "adding cluster edge node_18403-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_34224' 'eth_34224_18403' '22' 'None' '10.0.77.2/24' '10.0.77.1/24'
# node_18403-31133                                
echo "adding cluster edge node_18403-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_31133' 'eth_31133_18403' '22' 'None' '10.2.156.2/24' '10.2.156.1/24'
# node_18403-3356                                
echo "adding cluster edge node_18403-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_3356' 'eth_3356_18403' '22' 'None' '10.0.46.2/24' '10.0.46.1/24'
# node_18403-1299                                
echo "adding cluster edge node_18403-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_1299' 'eth_1299_18403' '22' 'None' '10.1.20.2/24' '10.1.20.1/24'
# node_18403-6453                                
echo "adding cluster edge node_18403-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_6453' 'eth_6453_18403' '22' 'None' '10.2.107.2/24' '10.2.107.1/24'
# node_18403-4637                                
echo "adding host edge node_18403-4637"                                
sleep 0.2                                
funCreateV 'eth_18403_4637' 'eth_4637_18403' '22' '24' '10.2.142.2/24' '10.2.142.1/24'
# node_4809-3356                                
echo "adding cluster edge node_4809-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4809_3356' 'eth_3356_4809' '23' 'None' '10.0.47.2/24' '10.0.47.1/24'
# node_4809-1299                                
echo "adding cluster edge node_4809-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4809_1299' 'eth_1299_4809' '23' 'None' '10.1.22.2/24' '10.1.22.1/24'
# node_4809-2914                                
echo "adding cluster edge node_4809-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4809_2914' 'eth_2914_4809' '23' 'None' '10.1.236.2/24' '10.1.236.1/24'
# node_4637-2519                                
echo "adding cluster edge node_4637-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_2519' 'eth_2519_4637' '24' 'None' '10.2.112.2/24' '10.2.112.1/24'
# node_4637-31133                                
echo "adding cluster edge node_4637-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_31133' 'eth_31133_4637' '24' 'None' '10.2.135.1/24' '10.2.135.2/24'
# node_4637-2914                                
echo "adding cluster edge node_4637-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_2914' 'eth_2914_4637' '24' 'None' '10.1.197.2/24' '10.1.197.1/24'
# node_4637-3303                                
echo "adding cluster edge node_4637-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_3303' 'eth_3303_4637' '24' 'None' '10.1.49.2/24' '10.1.49.1/24'
# node_4637-1299                                
echo "adding cluster edge node_4637-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_1299' 'eth_1299_4637' '24' 'None' '10.1.23.2/24' '10.1.23.1/24'
# node_4637-3257                                
echo "adding cluster edge node_4637-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_3257' 'eth_3257_4637' '24' 'None' '10.0.150.2/24' '10.0.150.1/24'
# node_4637-3356                                
echo "adding cluster edge node_4637-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_3356' 'eth_3356_4637' '24' 'None' '10.0.48.2/24' '10.0.48.1/24'
# node_4637-6453                                
echo "adding cluster edge node_4637-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_6453' 'eth_6453_4637' '24' 'None' '10.2.108.2/24' '10.2.108.1/24'