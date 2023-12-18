#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3356" "34224" "3549" "13335" "3303" "209" "1299" "174" "7018" "2519" "3257" "3741" "2914" "6762" "2516" "38040" "2152" "5511" "293" "4837" "1273" "1239" "6453" "31133" "64049" )
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
echo "adding host edge node_3356-3257"                                
sleep 0.2                                
funCreateV 'eth_3356_3257' 'eth_3257_3356' '0' '10' '10.0.9.1/24' '10.0.9.2/24'
# node_3356-3741                                
echo "adding host edge node_3356-3741"                                
sleep 0.2                                
funCreateV 'eth_3356_3741' 'eth_3741_3356' '0' '11' '10.0.10.1/24' '10.0.10.2/24'
# node_3356-2914                                
echo "adding host edge node_3356-2914"                                
sleep 0.2                                
funCreateV 'eth_3356_2914' 'eth_2914_3356' '0' '12' '10.0.11.1/24' '10.0.11.2/24'
# node_3356-6762                                
echo "adding host edge node_3356-6762"                                
sleep 0.2                                
funCreateV 'eth_3356_6762' 'eth_6762_3356' '0' '13' '10.0.12.1/24' '10.0.12.2/24'
# node_3356-2516                                
echo "adding host edge node_3356-2516"                                
sleep 0.2                                
funCreateV 'eth_3356_2516' 'eth_2516_3356' '0' '14' '10.0.13.1/24' '10.0.13.2/24'
# node_3356-38040                                
echo "adding host edge node_3356-38040"                                
sleep 0.2                                
funCreateV 'eth_3356_38040' 'eth_38040_3356' '0' '15' '10.0.14.1/24' '10.0.14.2/24'
# node_3356-2152                                
echo "adding host edge node_3356-2152"                                
sleep 0.2                                
funCreateV 'eth_3356_2152' 'eth_2152_3356' '0' '16' '10.0.15.1/24' '10.0.15.2/24'
# node_3356-5511                                
echo "adding host edge node_3356-5511"                                
sleep 0.2                                
funCreateV 'eth_3356_5511' 'eth_5511_3356' '0' '17' '10.0.16.1/24' '10.0.16.2/24'
# node_3356-293                                
echo "adding host edge node_3356-293"                                
sleep 0.2                                
funCreateV 'eth_3356_293' 'eth_293_3356' '0' '18' '10.0.17.1/24' '10.0.17.2/24'
# node_3356-4837                                
echo "adding host edge node_3356-4837"                                
sleep 0.2                                
funCreateV 'eth_3356_4837' 'eth_4837_3356' '0' '19' '10.0.18.1/24' '10.0.18.2/24'
# node_3356-1273                                
echo "adding host edge node_3356-1273"                                
sleep 0.2                                
funCreateV 'eth_3356_1273' 'eth_1273_3356' '0' '20' '10.0.19.1/24' '10.0.19.2/24'
# node_3356-1239                                
echo "adding host edge node_3356-1239"                                
sleep 0.2                                
funCreateV 'eth_3356_1239' 'eth_1239_3356' '0' '21' '10.0.20.1/24' '10.0.20.2/24'
# node_3356-6453                                
echo "adding host edge node_3356-6453"                                
sleep 0.2                                
funCreateV 'eth_3356_6453' 'eth_6453_3356' '0' '22' '10.0.21.1/24' '10.0.21.2/24'
# node_3356-31133                                
echo "adding host edge node_3356-31133"                                
sleep 0.2                                
funCreateV 'eth_3356_31133' 'eth_31133_3356' '0' '23' '10.0.22.1/24' '10.0.22.2/24'
# node_3356-64049                                
echo "adding host edge node_3356-64049"                                
sleep 0.2                                
funCreateV 'eth_3356_64049' 'eth_64049_3356' '0' '24' '10.0.23.1/24' '10.0.23.2/24'
# node_3356-6461                                
echo "adding cluster edge node_3356-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_6461' 'eth_6461_3356' '0' 'None' '10.0.24.1/24' '10.0.24.2/24'
# node_3356-3491                                
echo "adding cluster edge node_3356-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_3491' 'eth_3491_3356' '0' 'None' '10.0.25.1/24' '10.0.25.2/24'
# node_3356-6939                                
echo "adding cluster edge node_3356-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_6939' 'eth_6939_3356' '0' 'None' '10.0.26.1/24' '10.0.26.2/24'
# node_3356-9002                                
echo "adding cluster edge node_3356-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_9002' 'eth_9002_3356' '0' 'None' '10.0.27.1/24' '10.0.27.2/24'
# node_3356-37100                                
echo "adding cluster edge node_3356-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_37100' 'eth_37100_3356' '0' 'None' '10.0.28.1/24' '10.0.28.2/24'
# node_3356-3786                                
echo "adding cluster edge node_3356-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_3786' 'eth_3786_3356' '0' 'None' '10.0.29.1/24' '10.0.29.2/24'
# node_3356-5413                                
echo "adding cluster edge node_3356-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_5413' 'eth_5413_3356' '0' 'None' '10.0.30.1/24' '10.0.30.2/24'
# node_3356-701                                
echo "adding cluster edge node_3356-701"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_701' 'eth_701_3356' '0' 'None' '10.0.31.1/24' '10.0.31.2/24'
# node_3356-4134                                
echo "adding cluster edge node_3356-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4134' 'eth_4134_3356' '0' 'None' '10.0.32.1/24' '10.0.32.2/24'
# node_3356-132203                                
echo "adding cluster edge node_3356-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_132203' 'eth_132203_3356' '0' 'None' '10.0.33.1/24' '10.0.33.2/24'
# node_3356-4766                                
echo "adding cluster edge node_3356-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4766' 'eth_4766_3356' '0' 'None' '10.0.34.1/24' '10.0.34.2/24'
# node_3356-12552                                
echo "adding cluster edge node_3356-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_12552' 'eth_12552_3356' '0' 'None' '10.0.35.1/24' '10.0.35.2/24'
# node_3356-57866                                
echo "adding cluster edge node_3356-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_57866' 'eth_57866_3356' '0' 'None' '10.0.36.1/24' '10.0.36.2/24'
# node_3356-16735                                
echo "adding cluster edge node_3356-16735"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_16735' 'eth_16735_3356' '0' 'None' '10.0.37.1/24' '10.0.37.2/24'
# node_3356-33891                                
echo "adding cluster edge node_3356-33891"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_33891' 'eth_33891_3356' '0' 'None' '10.0.38.1/24' '10.0.38.2/24'
# node_3356-9607                                
echo "adding cluster edge node_3356-9607"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_9607' 'eth_9607_3356' '0' 'None' '10.0.39.1/24' '10.0.39.2/24'
# node_3356-55410                                
echo "adding cluster edge node_3356-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_55410' 'eth_55410_3356' '0' 'None' '10.0.40.1/24' '10.0.40.2/24'
# node_3356-2497                                
echo "adding cluster edge node_3356-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_2497' 'eth_2497_3356' '0' 'None' '10.0.41.1/24' '10.0.41.2/24'
# node_3356-9680                                
echo "adding cluster edge node_3356-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_9680' 'eth_9680_3356' '0' 'None' '10.0.42.1/24' '10.0.42.2/24'
# node_3356-4775                                
echo "adding cluster edge node_3356-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4775' 'eth_4775_3356' '0' 'None' '10.0.43.1/24' '10.0.43.2/24'
# node_3356-55644                                
echo "adding cluster edge node_3356-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_55644' 'eth_55644_3356' '0' 'None' '10.0.44.1/24' '10.0.44.2/24'
# node_3356-16509                                
echo "adding cluster edge node_3356-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_16509' 'eth_16509_3356' '0' 'None' '10.0.45.1/24' '10.0.45.2/24'
# node_3356-18403                                
echo "adding cluster edge node_3356-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_18403' 'eth_18403_3356' '0' 'None' '10.0.46.1/24' '10.0.46.2/24'
# node_3356-4809                                
echo "adding cluster edge node_3356-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4809' 'eth_4809_3356' '0' 'None' '10.0.47.1/24' '10.0.47.2/24'
# node_3356-4637                                
echo "adding cluster edge node_3356-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_3356_4637' 'eth_4637_3356' '0' 'None' '10.0.48.1/24' '10.0.48.2/24'
# node_34224-13335                                
echo "adding host edge node_34224-13335"                                
sleep 0.2                                
funCreateV 'eth_34224_13335' 'eth_13335_34224' '1' '3' '10.0.59.1/24' '10.0.59.2/24'
# node_34224-6939                                
echo "adding cluster edge node_34224-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_6939' 'eth_6939_34224' '1' 'None' '10.0.60.1/24' '10.0.60.2/24'
# node_34224-38040                                
echo "adding host edge node_34224-38040"                                
sleep 0.2                                
funCreateV 'eth_34224_38040' 'eth_38040_34224' '1' '15' '10.0.62.1/24' '10.0.62.2/24'
# node_34224-6453                                
echo "adding host edge node_34224-6453"                                
sleep 0.2                                
funCreateV 'eth_34224_6453' 'eth_6453_34224' '1' '22' '10.0.64.1/24' '10.0.64.2/24'
# node_34224-132203                                
echo "adding cluster edge node_34224-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_132203' 'eth_132203_34224' '1' 'None' '10.0.68.1/24' '10.0.68.2/24'
# node_34224-9002                                
echo "adding cluster edge node_34224-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_9002' 'eth_9002_34224' '1' 'None' '10.0.71.1/24' '10.0.71.2/24'
# node_34224-6762                                
echo "adding host edge node_34224-6762"                                
sleep 0.2                                
funCreateV 'eth_34224_6762' 'eth_6762_34224' '1' '13' '10.0.72.1/24' '10.0.72.2/24'
# node_34224-4775                                
echo "adding cluster edge node_34224-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_4775' 'eth_4775_34224' '1' 'None' '10.0.74.1/24' '10.0.74.2/24'
# node_34224-18403                                
echo "adding cluster edge node_34224-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_34224_18403' 'eth_18403_34224' '1' 'None' '10.0.77.1/24' '10.0.77.2/24'
# node_3549-4775                                
echo "adding cluster edge node_3549-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_3549_4775' 'eth_4775_3549' '2' 'None' '10.0.159.1/24' '10.0.159.2/24'
# node_13335-7018                                
echo "adding host edge node_13335-7018"                                
sleep 0.2                                
funCreateV 'eth_13335_7018' 'eth_7018_13335' '3' '8' '10.0.82.1/24' '10.0.82.2/24'
# node_13335-3257                                
echo "adding host edge node_13335-3257"                                
sleep 0.2                                
funCreateV 'eth_13335_3257' 'eth_3257_13335' '3' '10' '10.0.84.1/24' '10.0.84.2/24'
# node_13335-3741                                
echo "adding host edge node_13335-3741"                                
sleep 0.2                                
funCreateV 'eth_13335_3741' 'eth_3741_13335' '3' '11' '10.0.86.1/24' '10.0.86.2/24'
# node_13335-57866                                
echo "adding cluster edge node_13335-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_57866' 'eth_57866_13335' '3' 'None' '10.0.90.1/24' '10.0.90.2/24'
# node_13335-1299                                
echo "adding host edge node_13335-1299"                                
sleep 0.2                                
funCreateV 'eth_13335_1299' 'eth_1299_13335' '3' '6' '10.0.92.1/24' '10.0.92.2/24'
# node_13335-2152                                
echo "adding host edge node_13335-2152"                                
sleep 0.2                                
funCreateV 'eth_13335_2152' 'eth_2152_13335' '3' '16' '10.0.93.1/24' '10.0.93.2/24'
# node_13335-6939                                
echo "adding cluster edge node_13335-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_6939' 'eth_6939_13335' '3' 'None' '10.0.94.1/24' '10.0.94.2/24'
# node_13335-2497                                
echo "adding cluster edge node_13335-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_2497' 'eth_2497_13335' '3' 'None' '10.0.95.1/24' '10.0.95.2/24'
# node_13335-293                                
echo "adding host edge node_13335-293"                                
sleep 0.2                                
funCreateV 'eth_13335_293' 'eth_293_13335' '3' '18' '10.0.96.1/24' '10.0.96.2/24'
# node_13335-5413                                
echo "adding cluster edge node_13335-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_13335_5413' 'eth_5413_13335' '3' 'None' '10.0.97.1/24' '10.0.97.2/24'
# node_13335-2914                                
echo "adding host edge node_13335-2914"                                
sleep 0.2                                
funCreateV 'eth_13335_2914' 'eth_2914_13335' '3' '12' '10.0.98.1/24' '10.0.98.2/24'
# node_13335-1239                                
echo "adding host edge node_13335-1239"                                
sleep 0.2                                
funCreateV 'eth_13335_1239' 'eth_1239_13335' '3' '21' '10.0.101.1/24' '10.0.101.2/24'
# node_3303-6939                                
echo "adding cluster edge node_3303-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_6939' 'eth_6939_3303' '4' 'None' '10.1.29.1/24' '10.1.29.2/24'
# node_3303-2497                                
echo "adding cluster edge node_3303-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_2497' 'eth_2497_3303' '4' 'None' '10.1.31.1/24' '10.1.31.2/24'
# node_3303-38040                                
echo "adding host edge node_3303-38040"                                
sleep 0.2                                
funCreateV 'eth_3303_38040' 'eth_38040_3303' '4' '15' '10.1.32.1/24' '10.1.32.2/24'
# node_3303-4837                                
echo "adding host edge node_3303-4837"                                
sleep 0.2                                
funCreateV 'eth_3303_4837' 'eth_4837_3303' '4' '19' '10.1.34.1/24' '10.1.34.2/24'
# node_3303-6453                                
echo "adding host edge node_3303-6453"                                
sleep 0.2                                
funCreateV 'eth_3303_6453' 'eth_6453_3303' '4' '22' '10.1.35.1/24' '10.1.35.2/24'
# node_3303-2914                                
echo "adding host edge node_3303-2914"                                
sleep 0.2                                
funCreateV 'eth_3303_2914' 'eth_2914_3303' '4' '12' '10.1.37.1/24' '10.1.37.2/24'
# node_3303-174                                
echo "adding host edge node_3303-174"                                
sleep 0.2                                
funCreateV 'eth_3303_174' 'eth_174_3303' '4' '7' '10.1.38.1/24' '10.1.38.2/24'
# node_3303-3491                                
echo "adding cluster edge node_3303-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_3491' 'eth_3491_3303' '4' 'None' '10.1.40.1/24' '10.1.40.2/24'
# node_3303-64049                                
echo "adding host edge node_3303-64049"                                
sleep 0.2                                
funCreateV 'eth_3303_64049' 'eth_64049_3303' '4' '24' '10.1.42.1/24' '10.1.42.2/24'
# node_3303-3786                                
echo "adding cluster edge node_3303-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_3786' 'eth_3786_3303' '4' 'None' '10.1.43.1/24' '10.1.43.2/24'
# node_3303-4134                                
echo "adding cluster edge node_3303-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_4134' 'eth_4134_3303' '4' 'None' '10.1.45.1/24' '10.1.45.2/24'
# node_3303-132203                                
echo "adding cluster edge node_3303-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_132203' 'eth_132203_3303' '4' 'None' '10.1.46.1/24' '10.1.46.2/24'
# node_3303-4766                                
echo "adding cluster edge node_3303-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_4766' 'eth_4766_3303' '4' 'None' '10.1.47.1/24' '10.1.47.2/24'
# node_3303-4637                                
echo "adding cluster edge node_3303-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_4637' 'eth_4637_3303' '4' 'None' '10.1.49.1/24' '10.1.49.2/24'
# node_3303-1273                                
echo "adding host edge node_3303-1273"                                
sleep 0.2                                
funCreateV 'eth_3303_1273' 'eth_1273_3303' '4' '20' '10.1.50.1/24' '10.1.50.2/24'
# node_3303-9002                                
echo "adding cluster edge node_3303-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_9002' 'eth_9002_3303' '4' 'None' '10.1.52.1/24' '10.1.52.2/24'
# node_3303-6461                                
echo "adding cluster edge node_3303-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_3303_6461' 'eth_6461_3303' '4' 'None' '10.1.53.1/24' '10.1.53.2/24'
# node_3303-3257                                
echo "adding host edge node_3303-3257"                                
sleep 0.2                                
funCreateV 'eth_3303_3257' 'eth_3257_3303' '4' '10' '10.0.149.2/24' '10.0.149.1/24'
# node_1299-7018                                
echo "adding host edge node_1299-7018"                                
sleep 0.2                                
funCreateV 'eth_1299_7018' 'eth_7018_1299' '6' '8' '10.0.102.2/24' '10.0.102.1/24'
# node_1299-3257                                
echo "adding host edge node_1299-3257"                                
sleep 0.2                                
funCreateV 'eth_1299_3257' 'eth_3257_1299' '6' '10' '10.0.125.2/24' '10.0.125.1/24'
# node_1299-57866                                
echo "adding cluster edge node_1299-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_57866' 'eth_57866_1299' '6' 'None' '10.0.220.2/24' '10.0.220.1/24'
# node_1299-2519                                
echo "adding host edge node_1299-2519"                                
sleep 0.2                                
funCreateV 'eth_1299_2519' 'eth_2519_1299' '6' '9' '10.0.237.1/24' '10.0.237.2/24'
# node_1299-2497                                
echo "adding cluster edge node_1299-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_2497' 'eth_2497_1299' '6' 'None' '10.0.240.1/24' '10.0.240.2/24'
# node_1299-38040                                
echo "adding host edge node_1299-38040"                                
sleep 0.2                                
funCreateV 'eth_1299_38040' 'eth_38040_1299' '6' '15' '10.0.241.1/24' '10.0.241.2/24'
# node_1299-4837                                
echo "adding host edge node_1299-4837"                                
sleep 0.2                                
funCreateV 'eth_1299_4837' 'eth_4837_1299' '6' '19' '10.0.243.1/24' '10.0.243.2/24'
# node_1299-5413                                
echo "adding cluster edge node_1299-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_5413' 'eth_5413_1299' '6' 'None' '10.0.244.1/24' '10.0.244.2/24'
# node_1299-2914                                
echo "adding host edge node_1299-2914"                                
sleep 0.2                                
funCreateV 'eth_1299_2914' 'eth_2914_1299' '6' '12' '10.0.245.1/24' '10.0.245.2/24'
# node_1299-31133                                
echo "adding host edge node_1299-31133"                                
sleep 0.2                                
funCreateV 'eth_1299_31133' 'eth_31133_1299' '6' '23' '10.0.248.1/24' '10.0.248.2/24'
# node_1299-174                                
echo "adding host edge node_1299-174"                                
sleep 0.2                                
funCreateV 'eth_1299_174' 'eth_174_1299' '6' '7' '10.0.249.1/24' '10.0.249.2/24'
# node_1299-6453                                
echo "adding host edge node_1299-6453"                                
sleep 0.2                                
funCreateV 'eth_1299_6453' 'eth_6453_1299' '6' '22' '10.0.250.1/24' '10.0.250.2/24'
# node_1299-6939                                
echo "adding cluster edge node_1299-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_6939' 'eth_6939_1299' '6' 'None' '10.0.251.1/24' '10.0.251.2/24'
# node_1299-6762                                
echo "adding host edge node_1299-6762"                                
sleep 0.2                                
funCreateV 'eth_1299_6762' 'eth_6762_1299' '6' '13' '10.0.252.1/24' '10.0.252.2/24'
# node_1299-1273                                
echo "adding host edge node_1299-1273"                                
sleep 0.2                                
funCreateV 'eth_1299_1273' 'eth_1273_1299' '6' '20' '10.0.253.1/24' '10.0.253.2/24'
# node_1299-64049                                
echo "adding host edge node_1299-64049"                                
sleep 0.2                                
funCreateV 'eth_1299_64049' 'eth_64049_1299' '6' '24' '10.0.254.1/24' '10.0.254.2/24'
# node_1299-1239                                
echo "adding host edge node_1299-1239"                                
sleep 0.2                                
funCreateV 'eth_1299_1239' 'eth_1239_1299' '6' '21' '10.0.255.1/24' '10.0.255.2/24'
# node_1299-6461                                
echo "adding cluster edge node_1299-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_6461' 'eth_6461_1299' '6' 'None' '10.1.0.1/24' '10.1.0.2/24'
# node_1299-3491                                
echo "adding cluster edge node_1299-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_3491' 'eth_3491_1299' '6' 'None' '10.1.1.1/24' '10.1.1.2/24'
# node_1299-37100                                
echo "adding cluster edge node_1299-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_37100' 'eth_37100_1299' '6' 'None' '10.1.3.1/24' '10.1.3.2/24'
# node_1299-4134                                
echo "adding cluster edge node_1299-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4134' 'eth_4134_1299' '6' 'None' '10.1.5.1/24' '10.1.5.2/24'
# node_1299-132203                                
echo "adding cluster edge node_1299-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_132203' 'eth_132203_1299' '6' 'None' '10.1.6.1/24' '10.1.6.2/24'
# node_1299-4766                                
echo "adding cluster edge node_1299-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4766' 'eth_4766_1299' '6' 'None' '10.1.7.1/24' '10.1.7.2/24'
# node_1299-9002                                
echo "adding cluster edge node_1299-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_9002' 'eth_9002_1299' '6' 'None' '10.1.12.1/24' '10.1.12.2/24'
# node_1299-9680                                
echo "adding cluster edge node_1299-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_9680' 'eth_9680_1299' '6' 'None' '10.1.13.1/24' '10.1.13.2/24'
# node_1299-4775                                
echo "adding cluster edge node_1299-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4775' 'eth_4775_1299' '6' 'None' '10.1.14.1/24' '10.1.14.2/24'
# node_1299-16509                                
echo "adding cluster edge node_1299-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_16509' 'eth_16509_1299' '6' 'None' '10.1.15.1/24' '10.1.15.2/24'
# node_1299-18403                                
echo "adding cluster edge node_1299-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_18403' 'eth_18403_1299' '6' 'None' '10.1.20.1/24' '10.1.20.2/24'
# node_1299-4809                                
echo "adding cluster edge node_1299-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4809' 'eth_4809_1299' '6' 'None' '10.1.22.1/24' '10.1.22.2/24'
# node_1299-4637                                
echo "adding cluster edge node_1299-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_1299_4637' 'eth_4637_1299' '6' 'None' '10.1.23.1/24' '10.1.23.2/24'
# node_1299-5511                                
echo "adding host edge node_1299-5511"                                
sleep 0.2                                
funCreateV 'eth_1299_5511' 'eth_5511_1299' '6' '17' '10.1.26.1/24' '10.1.26.2/24'
# node_174-2519                                
echo "adding host edge node_174-2519"                                
sleep 0.2                                
funCreateV 'eth_174_2519' 'eth_2519_174' '7' '9' '10.2.56.1/24' '10.2.56.2/24'
# node_174-3741                                
echo "adding host edge node_174-3741"                                
sleep 0.2                                
funCreateV 'eth_174_3741' 'eth_3741_174' '7' '11' '10.0.163.2/24' '10.0.163.1/24'
# node_174-5511                                
echo "adding host edge node_174-5511"                                
sleep 0.2                                
funCreateV 'eth_174_5511' 'eth_5511_174' '7' '17' '10.2.57.1/24' '10.2.57.2/24'
# node_174-3491                                
echo "adding cluster edge node_174-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3491' 'eth_3491_174' '7' 'None' '10.2.58.1/24' '10.2.58.2/24'
# node_174-37100                                
echo "adding cluster edge node_174-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_174_37100' 'eth_37100_174' '7' 'None' '10.2.40.2/24' '10.2.40.1/24'
# node_174-7018                                
echo "adding host edge node_174-7018"                                
sleep 0.2                                
funCreateV 'eth_174_7018' 'eth_7018_174' '7' '8' '10.0.109.2/24' '10.0.109.1/24'
# node_174-3257                                
echo "adding host edge node_174-3257"                                
sleep 0.2                                
funCreateV 'eth_174_3257' 'eth_3257_174' '7' '10' '10.0.134.2/24' '10.0.134.1/24'
# node_174-31133                                
echo "adding host edge node_174-31133"                                
sleep 0.2                                
funCreateV 'eth_174_31133' 'eth_31133_174' '7' '23' '10.2.61.1/24' '10.2.61.2/24'
# node_174-2914                                
echo "adding host edge node_174-2914"                                
sleep 0.2                                
funCreateV 'eth_174_2914' 'eth_2914_174' '7' '12' '10.1.208.2/24' '10.1.208.1/24'
# node_174-1239                                
echo "adding host edge node_174-1239"                                
sleep 0.2                                
funCreateV 'eth_174_1239' 'eth_1239_174' '7' '21' '10.2.19.2/24' '10.2.19.1/24'
# node_174-6453                                
echo "adding host edge node_174-6453"                                
sleep 0.2                                
funCreateV 'eth_174_6453' 'eth_6453_174' '7' '22' '10.2.62.1/24' '10.2.62.2/24'
# node_174-38040                                
echo "adding host edge node_174-38040"                                
sleep 0.2                                
funCreateV 'eth_174_38040' 'eth_38040_174' '7' '15' '10.2.65.1/24' '10.2.65.2/24'
# node_174-4134                                
echo "adding cluster edge node_174-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_174_4134' 'eth_4134_174' '7' 'None' '10.2.67.1/24' '10.2.67.2/24'
# node_174-2497                                
echo "adding cluster edge node_174-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_174_2497' 'eth_2497_174' '7' 'None' '10.1.155.2/24' '10.1.155.1/24'
# node_174-1273                                
echo "adding host edge node_174-1273"                                
sleep 0.2                                
funCreateV 'eth_174_1273' 'eth_1273_174' '7' '20' '10.2.73.1/24' '10.2.73.2/24'
# node_174-6461                                
echo "adding cluster edge node_174-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_174_6461' 'eth_6461_174' '7' 'None' '10.2.75.1/24' '10.2.75.2/24'
# node_174-9680                                
echo "adding cluster edge node_174-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_174_9680' 'eth_9680_174' '7' 'None' '10.2.76.1/24' '10.2.76.2/24'
# node_174-55644                                
echo "adding cluster edge node_174-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_174_55644' 'eth_55644_174' '7' 'None' '10.2.77.1/24' '10.2.77.2/24'
# node_174-16509                                
echo "adding cluster edge node_174-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_174_16509' 'eth_16509_174' '7' 'None' '10.2.78.1/24' '10.2.78.2/24'
# node_174-4837                                
echo "adding host edge node_174-4837"                                
sleep 0.2                                
funCreateV 'eth_174_4837' 'eth_4837_174' '7' '19' '10.2.79.1/24' '10.2.79.2/24'
# node_174-6762                                
echo "adding host edge node_174-6762"                                
sleep 0.2                                
funCreateV 'eth_174_6762' 'eth_6762_174' '7' '13' '10.2.81.1/24' '10.2.81.2/24'
# node_174-3786                                
echo "adding cluster edge node_174-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_174_3786' 'eth_3786_174' '7' 'None' '10.2.83.1/24' '10.2.83.2/24'
# node_7018-2914                                
echo "adding host edge node_7018-2914"                                
sleep 0.2                                
funCreateV 'eth_7018_2914' 'eth_2914_7018' '8' '12' '10.0.103.1/24' '10.0.103.2/24'
# node_7018-2497                                
echo "adding cluster edge node_7018-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_2497' 'eth_2497_7018' '8' 'None' '10.0.104.1/24' '10.0.104.2/24'
# node_7018-6453                                
echo "adding host edge node_7018-6453"                                
sleep 0.2                                
funCreateV 'eth_7018_6453' 'eth_6453_7018' '8' '22' '10.0.105.1/24' '10.0.105.2/24'
# node_7018-5511                                
echo "adding host edge node_7018-5511"                                
sleep 0.2                                
funCreateV 'eth_7018_5511' 'eth_5511_7018' '8' '17' '10.0.106.1/24' '10.0.106.2/24'
# node_7018-4837                                
echo "adding host edge node_7018-4837"                                
sleep 0.2                                
funCreateV 'eth_7018_4837' 'eth_4837_7018' '8' '19' '10.0.107.1/24' '10.0.107.2/24'
# node_7018-1239                                
echo "adding host edge node_7018-1239"                                
sleep 0.2                                
funCreateV 'eth_7018_1239' 'eth_1239_7018' '8' '21' '10.0.108.1/24' '10.0.108.2/24'
# node_7018-6461                                
echo "adding cluster edge node_7018-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_6461' 'eth_6461_7018' '8' 'None' '10.0.110.1/24' '10.0.110.2/24'
# node_7018-3491                                
echo "adding cluster edge node_7018-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_3491' 'eth_3491_7018' '8' 'None' '10.0.111.1/24' '10.0.111.2/24'
# node_7018-4134                                
echo "adding cluster edge node_7018-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_4134' 'eth_4134_7018' '8' 'None' '10.0.112.1/24' '10.0.112.2/24'
# node_7018-701                                
echo "adding cluster edge node_7018-701"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_701' 'eth_701_7018' '8' 'None' '10.0.113.1/24' '10.0.113.2/24'
# node_7018-6939                                
echo "adding cluster edge node_7018-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_6939' 'eth_6939_7018' '8' 'None' '10.0.114.1/24' '10.0.114.2/24'
# node_7018-9680                                
echo "adding cluster edge node_7018-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_9680' 'eth_9680_7018' '8' 'None' '10.0.115.1/24' '10.0.115.2/24'
# node_7018-4775                                
echo "adding cluster edge node_7018-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_4775' 'eth_4775_7018' '8' 'None' '10.0.116.1/24' '10.0.116.2/24'
# node_7018-16509                                
echo "adding cluster edge node_7018-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_7018_16509' 'eth_16509_7018' '8' 'None' '10.0.117.1/24' '10.0.117.2/24'
# node_7018-3257                                
echo "adding host edge node_7018-3257"                                
sleep 0.2                                
funCreateV 'eth_7018_3257' 'eth_3257_7018' '8' '10' '10.0.118.1/24' '10.0.118.2/24'
# node_7018-6762                                
echo "adding host edge node_7018-6762"                                
sleep 0.2                                
funCreateV 'eth_7018_6762' 'eth_6762_7018' '8' '13' '10.0.120.1/24' '10.0.120.2/24'
# node_2519-2497                                
echo "adding cluster edge node_2519-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_2519_2497' 'eth_2497_2519' '9' 'None' '10.1.137.2/24' '10.1.137.1/24'
# node_2519-4637                                
echo "adding cluster edge node_2519-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_2519_4637' 'eth_4637_2519' '9' 'None' '10.2.112.1/24' '10.2.112.2/24'
# node_2519-6939                                
echo "adding cluster edge node_2519-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_2519_6939' 'eth_6939_2519' '9' 'None' '10.1.83.2/24' '10.1.83.1/24'
# node_3257-2914                                
echo "adding host edge node_3257-2914"                                
sleep 0.2                                
funCreateV 'eth_3257_2914' 'eth_2914_3257' '10' '12' '10.0.126.1/24' '10.0.126.2/24'
# node_3257-2497                                
echo "adding cluster edge node_3257-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_2497' 'eth_2497_3257' '10' 'None' '10.0.127.1/24' '10.0.127.2/24'
# node_3257-37100                                
echo "adding cluster edge node_3257-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_37100' 'eth_37100_3257' '10' 'None' '10.0.129.1/24' '10.0.129.2/24'
# node_3257-4837                                
echo "adding host edge node_3257-4837"                                
sleep 0.2                                
funCreateV 'eth_3257_4837' 'eth_4837_3257' '10' '19' '10.0.130.1/24' '10.0.130.2/24'
# node_3257-3491                                
echo "adding cluster edge node_3257-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_3491' 'eth_3491_3257' '10' 'None' '10.0.131.1/24' '10.0.131.2/24'
# node_3257-6453                                
echo "adding host edge node_3257-6453"                                
sleep 0.2                                
funCreateV 'eth_3257_6453' 'eth_6453_3257' '10' '22' '10.0.135.1/24' '10.0.135.2/24'
# node_3257-6461                                
echo "adding cluster edge node_3257-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_6461' 'eth_6461_3257' '10' 'None' '10.0.136.1/24' '10.0.136.2/24'
# node_3257-4134                                
echo "adding cluster edge node_3257-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_4134' 'eth_4134_3257' '10' 'None' '10.0.137.1/24' '10.0.137.2/24'
# node_3257-4766                                
echo "adding cluster edge node_3257-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_4766' 'eth_4766_3257' '10' 'None' '10.0.138.1/24' '10.0.138.2/24'
# node_3257-1239                                
echo "adding host edge node_3257-1239"                                
sleep 0.2                                
funCreateV 'eth_3257_1239' 'eth_1239_3257' '10' '21' '10.0.140.1/24' '10.0.140.2/24'
# node_3257-1273                                
echo "adding host edge node_3257-1273"                                
sleep 0.2                                
funCreateV 'eth_3257_1273' 'eth_1273_3257' '10' '20' '10.0.141.1/24' '10.0.141.2/24'
# node_3257-16509                                
echo "adding cluster edge node_3257-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_16509' 'eth_16509_3257' '10' 'None' '10.0.144.1/24' '10.0.144.2/24'
# node_3257-4637                                
echo "adding cluster edge node_3257-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_4637' 'eth_4637_3257' '10' 'None' '10.0.150.1/24' '10.0.150.2/24'
# node_3257-5511                                
echo "adding host edge node_3257-5511"                                
sleep 0.2                                
funCreateV 'eth_3257_5511' 'eth_5511_3257' '10' '17' '10.0.152.1/24' '10.0.152.2/24'
# node_3257-6762                                
echo "adding host edge node_3257-6762"                                
sleep 0.2                                
funCreateV 'eth_3257_6762' 'eth_6762_3257' '10' '13' '10.0.154.1/24' '10.0.154.2/24'
# node_3741-6939                                
echo "adding cluster edge node_3741-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_6939' 'eth_6939_3741' '11' 'None' '10.0.160.1/24' '10.0.160.2/24'
# node_3741-9002                                
echo "adding cluster edge node_3741-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_9002' 'eth_9002_3741' '11' 'None' '10.0.164.1/24' '10.0.164.2/24'
# node_3741-4134                                
echo "adding cluster edge node_3741-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_4134' 'eth_4134_3741' '11' 'None' '10.0.165.1/24' '10.0.165.2/24'
# node_3741-2914                                
echo "adding host edge node_3741-2914"                                
sleep 0.2                                
funCreateV 'eth_3741_2914' 'eth_2914_3741' '11' '12' '10.0.166.1/24' '10.0.166.2/24'
# node_3741-6461                                
echo "adding cluster edge node_3741-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_6461' 'eth_6461_3741' '11' 'None' '10.0.167.1/24' '10.0.167.2/24'
# node_3741-64049                                
echo "adding host edge node_3741-64049"                                
sleep 0.2                                
funCreateV 'eth_3741_64049' 'eth_64049_3741' '11' '24' '10.0.168.1/24' '10.0.168.2/24'
# node_2914-6453                                
echo "adding host edge node_2914-6453"                                
sleep 0.2                                
funCreateV 'eth_2914_6453' 'eth_6453_2914' '12' '22' '10.1.194.1/24' '10.1.194.2/24'
# node_2914-293                                
echo "adding host edge node_2914-293"                                
sleep 0.2                                
funCreateV 'eth_2914_293' 'eth_293_2914' '12' '18' '10.1.171.2/24' '10.1.171.1/24'
# node_2914-6461                                
echo "adding cluster edge node_2914-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_6461' 'eth_6461_2914' '12' 'None' '10.1.196.1/24' '10.1.196.2/24'
# node_2914-57866                                
echo "adding cluster edge node_2914-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_57866' 'eth_57866_2914' '12' 'None' '10.0.221.2/24' '10.0.221.1/24'
# node_2914-4637                                
echo "adding cluster edge node_2914-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_4637' 'eth_4637_2914' '12' 'None' '10.1.197.1/24' '10.1.197.2/24'
# node_2914-38040                                
echo "adding host edge node_2914-38040"                                
sleep 0.2                                
funCreateV 'eth_2914_38040' 'eth_38040_2914' '12' '15' '10.1.198.1/24' '10.1.198.2/24'
# node_2914-4837                                
echo "adding host edge node_2914-4837"                                
sleep 0.2                                
funCreateV 'eth_2914_4837' 'eth_4837_2914' '12' '19' '10.1.200.1/24' '10.1.200.2/24'
# node_2914-1239                                
echo "adding host edge node_2914-1239"                                
sleep 0.2                                
funCreateV 'eth_2914_1239' 'eth_1239_2914' '12' '21' '10.1.205.1/24' '10.1.205.2/24'
# node_2914-37100                                
echo "adding cluster edge node_2914-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_37100' 'eth_37100_2914' '12' 'None' '10.1.206.1/24' '10.1.206.2/24'
# node_2914-3491                                
echo "adding cluster edge node_2914-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_3491' 'eth_3491_2914' '12' 'None' '10.1.207.1/24' '10.1.207.2/24'
# node_2914-2497                                
echo "adding cluster edge node_2914-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_2497' 'eth_2497_2914' '12' 'None' '10.1.140.2/24' '10.1.140.1/24'
# node_2914-64049                                
echo "adding host edge node_2914-64049"                                
sleep 0.2                                
funCreateV 'eth_2914_64049' 'eth_64049_2914' '12' '24' '10.1.209.1/24' '10.1.209.2/24'
# node_2914-3786                                
echo "adding cluster edge node_2914-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_3786' 'eth_3786_2914' '12' 'None' '10.1.212.1/24' '10.1.212.2/24'
# node_2914-4134                                
echo "adding cluster edge node_2914-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_4134' 'eth_4134_2914' '12' 'None' '10.1.215.1/24' '10.1.215.2/24'
# node_2914-132203                                
echo "adding cluster edge node_2914-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_132203' 'eth_132203_2914' '12' 'None' '10.1.216.1/24' '10.1.216.2/24'
# node_2914-4766                                
echo "adding cluster edge node_2914-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_4766' 'eth_4766_2914' '12' 'None' '10.1.217.1/24' '10.1.217.2/24'
# node_2914-6762                                
echo "adding host edge node_2914-6762"                                
sleep 0.2                                
funCreateV 'eth_2914_6762' 'eth_6762_2914' '12' '13' '10.1.220.1/24' '10.1.220.2/24'
# node_2914-1273                                
echo "adding host edge node_2914-1273"                                
sleep 0.2                                
funCreateV 'eth_2914_1273' 'eth_1273_2914' '12' '20' '10.1.224.1/24' '10.1.224.2/24'
# node_2914-4775                                
echo "adding cluster edge node_2914-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_4775' 'eth_4775_2914' '12' 'None' '10.1.229.1/24' '10.1.229.2/24'
# node_2914-16509                                
echo "adding cluster edge node_2914-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_16509' 'eth_16509_2914' '12' 'None' '10.1.230.1/24' '10.1.230.2/24'
# node_2914-18403                                
echo "adding cluster edge node_2914-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_18403' 'eth_18403_2914' '12' 'None' '10.1.234.1/24' '10.1.234.2/24'
# node_2914-4809                                
echo "adding cluster edge node_2914-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_4809' 'eth_4809_2914' '12' 'None' '10.1.236.1/24' '10.1.236.2/24'
# node_2914-5413                                
echo "adding cluster edge node_2914-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_5413' 'eth_5413_2914' '12' 'None' '10.1.192.2/24' '10.1.192.1/24'
# node_2914-5511                                
echo "adding host edge node_2914-5511"                                
sleep 0.2                                
funCreateV 'eth_2914_5511' 'eth_5511_2914' '12' '17' '10.1.238.1/24' '10.1.238.2/24'
# node_6762-37100                                
echo "adding cluster edge node_6762-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_37100' 'eth_37100_6762' '13' 'None' '10.2.41.2/24' '10.2.41.1/24'
# node_6762-6453                                
echo "adding host edge node_6762-6453"                                
sleep 0.2                                
funCreateV 'eth_6762_6453' 'eth_6453_6762' '13' '22' '10.2.95.2/24' '10.2.95.1/24'
# node_6762-38040                                
echo "adding host edge node_6762-38040"                                
sleep 0.2                                
funCreateV 'eth_6762_38040' 'eth_38040_6762' '13' '15' '10.2.170.1/24' '10.2.170.2/24'
# node_6762-9680                                
echo "adding cluster edge node_6762-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_9680' 'eth_9680_6762' '13' 'None' '10.2.171.1/24' '10.2.171.2/24'
# node_6762-1273                                
echo "adding host edge node_6762-1273"                                
sleep 0.2                                
funCreateV 'eth_6762_1273' 'eth_1273_6762' '13' '20' '10.2.173.1/24' '10.2.173.2/24'
# node_6762-3491                                
echo "adding cluster edge node_6762-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_3491' 'eth_3491_6762' '13' 'None' '10.2.174.1/24' '10.2.174.2/24'
# node_6762-4134                                
echo "adding cluster edge node_6762-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_4134' 'eth_4134_6762' '13' 'None' '10.2.175.1/24' '10.2.175.2/24'
# node_6762-6939                                
echo "adding cluster edge node_6762-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_6939' 'eth_6939_6762' '13' 'None' '10.1.131.2/24' '10.1.131.1/24'
# node_6762-5511                                
echo "adding host edge node_6762-5511"                                
sleep 0.2                                
funCreateV 'eth_6762_5511' 'eth_5511_6762' '13' '17' '10.2.177.1/24' '10.2.177.2/24'
# node_6762-1239                                
echo "adding host edge node_6762-1239"                                
sleep 0.2                                
funCreateV 'eth_6762_1239' 'eth_1239_6762' '13' '21' '10.2.34.2/24' '10.2.34.1/24'
# node_2516-2152                                
echo "adding host edge node_2516-2152"                                
sleep 0.2                                
funCreateV 'eth_2516_2152' 'eth_2152_2516' '14' '16' '10.1.61.2/24' '10.1.61.1/24'
# node_38040-6939                                
echo "adding cluster edge node_38040-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_6939' 'eth_6939_38040' '15' 'None' '10.1.86.2/24' '10.1.86.1/24'
# node_38040-6453                                
echo "adding host edge node_38040-6453"                                
sleep 0.2                                
funCreateV 'eth_38040_6453' 'eth_6453_38040' '15' '22' '10.2.85.2/24' '10.2.85.1/24'
# node_38040-2497                                
echo "adding cluster edge node_38040-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_2497' 'eth_2497_38040' '15' 'None' '10.1.145.2/24' '10.1.145.1/24'
# node_38040-9002                                
echo "adding cluster edge node_38040-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_9002' 'eth_9002_38040' '15' 'None' '10.2.219.1/24' '10.2.219.2/24'
# node_38040-3491                                
echo "adding cluster edge node_38040-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_3491' 'eth_3491_38040' '15' 'None' '10.2.220.1/24' '10.2.220.2/24'
# node_38040-12552                                
echo "adding cluster edge node_38040-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_12552' 'eth_12552_38040' '15' 'None' '10.2.132.2/24' '10.2.132.1/24'
# node_38040-293                                
echo "adding host edge node_38040-293"                                
sleep 0.2                                
funCreateV 'eth_38040_293' 'eth_293_38040' '15' '18' '10.1.182.2/24' '10.1.182.1/24'
# node_2152-6939                                
echo "adding cluster edge node_2152-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_6939' 'eth_6939_2152' '16' 'None' '10.1.58.1/24' '10.1.58.2/24'
# node_2152-1239                                
echo "adding host edge node_2152-1239"                                
sleep 0.2                                
funCreateV 'eth_2152_1239' 'eth_1239_2152' '16' '21' '10.1.60.1/24' '10.1.60.2/24'
# node_2152-6461                                
echo "adding cluster edge node_2152-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_6461' 'eth_6461_2152' '16' 'None' '10.1.62.1/24' '10.1.62.2/24'
# node_2152-3786                                
echo "adding cluster edge node_2152-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_3786' 'eth_3786_2152' '16' 'None' '10.1.64.1/24' '10.1.64.2/24'
# node_2152-132203                                
echo "adding cluster edge node_2152-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_132203' 'eth_132203_2152' '16' 'None' '10.1.66.1/24' '10.1.66.2/24'
# node_2152-4766                                
echo "adding cluster edge node_2152-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_4766' 'eth_4766_2152' '16' 'None' '10.1.67.1/24' '10.1.67.2/24'
# node_2152-9680                                
echo "adding cluster edge node_2152-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_9680' 'eth_9680_2152' '16' 'None' '10.1.68.1/24' '10.1.68.2/24'
# node_2152-16509                                
echo "adding cluster edge node_2152-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_16509' 'eth_16509_2152' '16' 'None' '10.1.69.1/24' '10.1.69.2/24'
# node_5511-4837                                
echo "adding host edge node_5511-4837"                                
sleep 0.2                                
funCreateV 'eth_5511_4837' 'eth_4837_5511' '17' '19' '10.3.8.2/24' '10.3.8.1/24'
# node_5511-6939                                
echo "adding cluster edge node_5511-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_6939' 'eth_6939_5511' '17' 'None' '10.1.88.2/24' '10.1.88.1/24'
# node_5511-1239                                
echo "adding host edge node_5511-1239"                                
sleep 0.2                                
funCreateV 'eth_5511_1239' 'eth_1239_5511' '17' '21' '10.2.16.2/24' '10.2.16.1/24'
# node_5511-6461                                
echo "adding cluster edge node_5511-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_6461' 'eth_6461_5511' '17' 'None' '10.2.195.2/24' '10.2.195.1/24'
# node_5511-2497                                
echo "adding cluster edge node_5511-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_2497' 'eth_2497_5511' '17' 'None' '10.1.169.2/24' '10.1.169.1/24'
# node_5511-6453                                
echo "adding host edge node_5511-6453"                                
sleep 0.2                                
funCreateV 'eth_5511_6453' 'eth_6453_5511' '17' '22' '10.2.109.2/24' '10.2.109.1/24'
# node_293-6939                                
echo "adding cluster edge node_293-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_293_6939' 'eth_6939_293' '18' 'None' '10.1.81.2/24' '10.1.81.1/24'
# node_293-2497                                
echo "adding cluster edge node_293-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_293_2497' 'eth_2497_293' '18' 'None' '10.1.144.2/24' '10.1.144.1/24'
# node_293-6453                                
echo "adding host edge node_293-6453"                                
sleep 0.2                                
funCreateV 'eth_293_6453' 'eth_6453_293' '18' '22' '10.1.172.1/24' '10.1.172.2/24'
# node_293-3491                                
echo "adding cluster edge node_293-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_293_3491' 'eth_3491_293' '18' 'None' '10.1.173.1/24' '10.1.173.2/24'
# node_293-1273                                
echo "adding host edge node_293-1273"                                
sleep 0.2                                
funCreateV 'eth_293_1273' 'eth_1273_293' '18' '20' '10.1.175.1/24' '10.1.175.2/24'
# node_293-9002                                
echo "adding cluster edge node_293-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_293_9002' 'eth_9002_293' '18' 'None' '10.1.177.1/24' '10.1.177.2/24'
# node_4837-6461                                
echo "adding cluster edge node_4837-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_6461' 'eth_6461_4837' '19' 'None' '10.2.183.2/24' '10.2.183.1/24'
# node_4837-6453                                
echo "adding host edge node_4837-6453"                                
sleep 0.2                                
funCreateV 'eth_4837_6453' 'eth_6453_4837' '19' '22' '10.2.86.2/24' '10.2.86.1/24'
# node_4837-2497                                
echo "adding cluster edge node_4837-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_2497' 'eth_2497_4837' '19' 'None' '10.1.146.2/24' '10.1.146.1/24'
# node_4837-6939                                
echo "adding cluster edge node_4837-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_6939' 'eth_6939_4837' '19' 'None' '10.1.108.2/24' '10.1.108.1/24'
# node_4837-4134                                
echo "adding cluster edge node_4837-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_4134' 'eth_4134_4837' '19' 'None' '10.3.12.1/24' '10.3.12.2/24'
# node_4837-701                                
echo "adding cluster edge node_4837-701"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_701' 'eth_701_4837' '19' 'None' '10.3.14.1/24' '10.3.14.2/24'
# node_4837-1239                                
echo "adding host edge node_4837-1239"                                
sleep 0.2                                
funCreateV 'eth_4837_1239' 'eth_1239_4837' '19' '21' '10.2.25.2/24' '10.2.25.1/24'
# node_1273-6453                                
echo "adding host edge node_1273-6453"                                
sleep 0.2                                
funCreateV 'eth_1273_6453' 'eth_6453_1273' '20' '22' '10.2.96.2/24' '10.2.96.1/24'
# node_1273-55410                                
echo "adding cluster edge node_1273-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_55410' 'eth_55410_1273' '20' 'None' '10.3.84.1/24' '10.3.84.2/24'
# node_1273-2497                                
echo "adding cluster edge node_1273-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_2497' 'eth_2497_1273' '20' 'None' '10.1.158.2/24' '10.1.158.1/24'
# node_1273-1239                                
echo "adding host edge node_1273-1239"                                
sleep 0.2                                
funCreateV 'eth_1273_1239' 'eth_1239_1273' '20' '21' '10.2.24.2/24' '10.2.24.1/24'
# node_1273-6939                                
echo "adding cluster edge node_1273-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_6939' 'eth_6939_1273' '20' 'None' '10.1.106.2/24' '10.1.106.1/24'
# node_1273-6461                                
echo "adding cluster edge node_1273-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_6461' 'eth_6461_1273' '20' 'None' '10.2.191.2/24' '10.2.191.1/24'
# node_1273-55644                                
echo "adding cluster edge node_1273-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_55644' 'eth_55644_1273' '20' 'None' '10.3.87.1/24' '10.3.87.2/24'
# node_1239-4766                                
echo "adding cluster edge node_1239-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_4766' 'eth_4766_1239' '21' 'None' '10.2.15.1/24' '10.2.15.2/24'
# node_1239-6453                                
echo "adding host edge node_1239-6453"                                
sleep 0.2                                
funCreateV 'eth_1239_6453' 'eth_6453_1239' '21' '22' '10.2.17.1/24' '10.2.17.2/24'
# node_1239-6939                                
echo "adding cluster edge node_1239-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_6939' 'eth_6939_1239' '21' 'None' '10.1.90.2/24' '10.1.90.1/24'
# node_1239-6461                                
echo "adding cluster edge node_1239-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_6461' 'eth_6461_1239' '21' 'None' '10.2.20.1/24' '10.2.20.2/24'
# node_1239-3491                                
echo "adding cluster edge node_1239-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_3491' 'eth_3491_1239' '21' 'None' '10.2.21.1/24' '10.2.21.2/24'
# node_1239-3786                                
echo "adding cluster edge node_1239-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_3786' 'eth_3786_1239' '21' 'None' '10.2.22.1/24' '10.2.22.2/24'
# node_1239-701                                
echo "adding cluster edge node_1239-701"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_701' 'eth_701_1239' '21' 'None' '10.2.26.1/24' '10.2.26.2/24'
# node_1239-4775                                
echo "adding cluster edge node_1239-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_4775' 'eth_4775_1239' '21' 'None' '10.2.29.1/24' '10.2.29.2/24'
# node_1239-16509                                
echo "adding cluster edge node_1239-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_16509' 'eth_16509_1239' '21' 'None' '10.2.30.1/24' '10.2.30.2/24'
# node_6453-2497                                
echo "adding cluster edge node_6453-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_2497' 'eth_2497_6453' '22' 'None' '10.1.135.2/24' '10.1.135.1/24'
# node_6453-37100                                
echo "adding cluster edge node_6453-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_37100' 'eth_37100_6453' '22' 'None' '10.2.38.2/24' '10.2.38.1/24'
# node_6453-6461                                
echo "adding cluster edge node_6453-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_6461' 'eth_6461_6453' '22' 'None' '10.2.88.1/24' '10.2.88.2/24'
# node_6453-57866                                
echo "adding cluster edge node_6453-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_57866' 'eth_57866_6453' '22' 'None' '10.0.224.2/24' '10.0.224.1/24'
# node_6453-4134                                
echo "adding cluster edge node_6453-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_4134' 'eth_4134_6453' '22' 'None' '10.2.99.1/24' '10.2.99.2/24'
# node_6453-9002                                
echo "adding cluster edge node_6453-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_9002' 'eth_9002_6453' '22' 'None' '10.2.101.1/24' '10.2.101.2/24'
# node_6453-3491                                
echo "adding cluster edge node_6453-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_3491' 'eth_3491_6453' '22' 'None' '10.2.102.1/24' '10.2.102.2/24'
# node_6453-4775                                
echo "adding cluster edge node_6453-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_4775' 'eth_4775_6453' '22' 'None' '10.2.104.1/24' '10.2.104.2/24'
# node_6453-16509                                
echo "adding cluster edge node_6453-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_16509' 'eth_16509_6453' '22' 'None' '10.2.105.1/24' '10.2.105.2/24'
# node_6453-18403                                
echo "adding cluster edge node_6453-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_18403' 'eth_18403_6453' '22' 'None' '10.2.107.1/24' '10.2.107.2/24'
# node_6453-4637                                
echo "adding cluster edge node_6453-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_4637' 'eth_4637_6453' '22' 'None' '10.2.108.1/24' '10.2.108.2/24'
# node_6453-3786                                
echo "adding cluster edge node_6453-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_3786' 'eth_3786_6453' '22' 'None' '10.2.111.1/24' '10.2.111.2/24'
# node_31133-4637                                
echo "adding cluster edge node_31133-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_4637' 'eth_4637_31133' '23' 'None' '10.2.135.2/24' '10.2.135.1/24'
# node_31133-3786                                
echo "adding cluster edge node_31133-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_3786' 'eth_3786_31133' '23' 'None' '10.2.148.1/24' '10.2.148.2/24'
# node_31133-4134                                
echo "adding cluster edge node_31133-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_4134' 'eth_4134_31133' '23' 'None' '10.2.149.1/24' '10.2.149.2/24'
# node_31133-4766                                
echo "adding cluster edge node_31133-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_4766' 'eth_4766_31133' '23' 'None' '10.2.150.1/24' '10.2.150.2/24'
# node_31133-18403                                
echo "adding cluster edge node_31133-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_31133_18403' 'eth_18403_31133' '23' 'None' '10.2.156.1/24' '10.2.156.2/24'
# node_64049-37100                                
echo "adding cluster edge node_64049-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_37100' 'eth_37100_64049' '24' 'None' '10.2.43.2/24' '10.2.43.1/24'
# node_64049-6939                                
echo "adding cluster edge node_64049-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_6939' 'eth_6939_64049' '24' 'None' '10.1.92.2/24' '10.1.92.1/24'
# node_64049-12552                                
echo "adding cluster edge node_64049-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_12552' 'eth_12552_64049' '24' 'None' '10.2.118.2/24' '10.2.118.1/24'