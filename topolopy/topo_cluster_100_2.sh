#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("136907" "7303" "6663" "12479" "15169" "9505" "9957" "4657" "45974" "23764" "9304" "4651" "702" "4788" "9318" "8763" "9498" "3462" "58453" "9605" "10158" "20912" "49788" "18106" "11686" "22652" "8492" "23673" "1403" "17676" "7473" "3320" "3561" "7545" "15412" "9583" "24785" "64050" "10089" "15932" "4538" "4826" "6830" "20764" "1237" "20485" "7497" "9929" "7670" "23352" )
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
# node_136907-3356                                
echo "adding cluster edge node_136907-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_136907_3356' 'eth_3356_136907' '0' 'None' '10.0.49.2/24' '10.0.49.1/24'
# node_136907-6939                                
echo "adding cluster edge node_136907-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_136907_6939' 'eth_6939_136907' '0' 'None' '10.1.130.2/24' '10.1.130.1/24'
# node_136907-7303                                
echo "adding host edge node_136907-7303"                                
sleep 0.2                                
funCreateV 'eth_136907_7303' 'eth_7303_136907' '0' '1' '10.3.231.1/24' '10.3.231.2/24'
# node_7303-3356                                
echo "adding cluster edge node_7303-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_7303_3356' 'eth_3356_7303' '1' 'None' '10.0.50.2/24' '10.0.50.1/24'
# node_7303-6762                                
echo "adding cluster edge node_7303-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_7303_6762' 'eth_6762_7303' '1' 'None' '10.2.176.2/24' '10.2.176.1/24'
# node_6663-3356                                
echo "adding cluster edge node_6663-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_3356' 'eth_3356_6663' '2' 'None' '10.0.51.2/24' '10.0.51.1/24'
# node_6663-1299                                
echo "adding cluster edge node_6663-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_1299' 'eth_1299_6663' '2' 'None' '10.1.25.2/24' '10.1.25.1/24'
# node_6663-18106                                
echo "adding host edge node_6663-18106"                                
sleep 0.2                                
funCreateV 'eth_6663_18106' 'eth_18106_6663' '2' '23' '10.0.204.2/24' '10.0.204.1/24'
# node_6663-12552                                
echo "adding cluster edge node_6663-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_12552' 'eth_12552_6663' '2' 'None' '10.2.130.2/24' '10.2.130.1/24'
# node_6663-34224                                
echo "adding cluster edge node_6663-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_34224' 'eth_34224_6663' '2' 'None' '10.0.79.2/24' '10.0.79.1/24'
# node_6663-2914                                
echo "adding cluster edge node_6663-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_2914' 'eth_2914_6663' '2' 'None' '10.1.237.2/24' '10.1.237.1/24'
# node_12479-5511                                
echo "adding cluster edge node_12479-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_12479_5511' 'eth_5511_12479' '3' 'None' '10.3.22.2/24' '10.3.22.1/24'
# node_12479-6939                                
echo "adding cluster edge node_12479-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_12479_6939' 'eth_6939_12479' '3' 'None' '10.1.132.2/24' '10.1.132.1/24'
# node_12479-1239                                
echo "adding cluster edge node_12479-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_12479_1239' 'eth_1239_12479' '3' 'None' '10.2.33.2/24' '10.2.33.1/24'
# node_12479-3356                                
echo "adding cluster edge node_12479-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_12479_3356' 'eth_3356_12479' '3' 'None' '10.0.52.2/24' '10.0.52.1/24'
# node_15169-37100                                
echo "adding cluster edge node_15169-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_37100' 'eth_37100_15169' '4' 'None' '10.2.52.2/24' '10.2.52.1/24'
# node_15169-7018                                
echo "adding cluster edge node_15169-7018"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_7018' 'eth_7018_15169' '4' 'None' '10.0.119.2/24' '10.0.119.1/24'
# node_15169-20912                                
echo "adding host edge node_15169-20912"                                
sleep 0.2                                
funCreateV 'eth_15169_20912' 'eth_20912_15169' '4' '21' '10.0.124.2/24' '10.0.124.1/24'
# node_15169-3257                                
echo "adding cluster edge node_15169-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_3257' 'eth_3257_15169' '4' 'None' '10.0.153.2/24' '10.0.153.1/24'
# node_15169-3356                                
echo "adding cluster edge node_15169-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_3356' 'eth_3356_15169' '4' 'None' '10.0.53.2/24' '10.0.53.1/24'
# node_15169-3741                                
echo "adding cluster edge node_15169-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_3741' 'eth_3741_15169' '4' 'None' '10.0.174.2/24' '10.0.174.1/24'
# node_15169-18106                                
echo "adding host edge node_15169-18106"                                
sleep 0.2                                
funCreateV 'eth_15169_18106' 'eth_18106_15169' '4' '23' '10.0.205.2/24' '10.0.205.1/24'
# node_15169-12552                                
echo "adding cluster edge node_15169-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_12552' 'eth_12552_15169' '4' 'None' '10.2.131.2/24' '10.2.131.1/24'
# node_15169-11686                                
echo "adding host edge node_15169-11686"                                
sleep 0.2                                
funCreateV 'eth_15169_11686' 'eth_11686_15169' '4' '24' '10.0.212.2/24' '10.0.212.1/24'
# node_15169-34224                                
echo "adding cluster edge node_15169-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_34224' 'eth_34224_15169' '4' 'None' '10.0.80.2/24' '10.0.80.1/24'
# node_15169-22652                                
echo "adding host edge node_15169-22652"                                
sleep 0.2                                
funCreateV 'eth_15169_22652' 'eth_22652_15169' '4' '25' '10.0.219.2/24' '10.0.219.1/24'
# node_15169-57866                                
echo "adding cluster edge node_15169-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_57866' 'eth_57866_15169' '4' 'None' '10.0.226.2/24' '10.0.226.1/24'
# node_15169-8492                                
echo "adding host edge node_15169-8492"                                
sleep 0.2                                
funCreateV 'eth_15169_8492' 'eth_8492_15169' '4' '26' '10.0.235.2/24' '10.0.235.1/24'
# node_15169-1299                                
echo "adding cluster edge node_15169-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_1299' 'eth_1299_15169' '4' 'None' '10.1.27.2/24' '10.1.27.1/24'
# node_15169-293                                
echo "adding cluster edge node_15169-293"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_293' 'eth_293_15169' '4' 'None' '10.1.181.2/24' '10.1.181.1/24'
# node_15169-6939                                
echo "adding cluster edge node_15169-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_6939' 'eth_6939_15169' '4' 'None' '10.1.133.2/24' '10.1.133.1/24'
# node_15169-5413                                
echo "adding cluster edge node_15169-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_5413' 'eth_5413_15169' '4' 'None' '10.1.193.2/24' '10.1.193.1/24'
# node_15169-3303                                
echo "adding cluster edge node_15169-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_3303' 'eth_3303_15169' '4' 'None' '10.1.57.2/24' '10.1.57.1/24'
# node_15169-23673                                
echo "adding host edge node_15169-23673"                                
sleep 0.2                                
funCreateV 'eth_15169_23673' 'eth_23673_15169' '4' '27' '10.1.255.2/24' '10.1.255.1/24'
# node_15169-2497                                
echo "adding cluster edge node_15169-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_2497' 'eth_2497_15169' '4' 'None' '10.1.170.2/24' '10.1.170.1/24'
# node_15169-2914                                
echo "adding cluster edge node_15169-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_2914' 'eth_2914_15169' '4' 'None' '10.1.239.2/24' '10.1.239.1/24'
# node_15169-2152                                
echo "adding cluster edge node_15169-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_2152' 'eth_2152_15169' '4' 'None' '10.1.70.2/24' '10.1.70.1/24'
# node_15169-1403                                
echo "adding host edge node_15169-1403"                                
sleep 0.2                                
funCreateV 'eth_15169_1403' 'eth_1403_15169' '4' '28' '10.2.8.2/24' '10.2.8.1/24'
# node_9505-3356                                
echo "adding cluster edge node_9505-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_3356' 'eth_3356_9505' '5' 'None' '10.0.54.2/24' '10.0.54.1/24'
# node_9505-18106                                
echo "adding host edge node_9505-18106"                                
sleep 0.2                                
funCreateV 'eth_9505_18106' 'eth_18106_9505' '5' '23' '10.0.206.2/24' '10.0.206.1/24'
# node_9505-12552                                
echo "adding cluster edge node_9505-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_12552' 'eth_12552_9505' '5' 'None' '10.2.133.2/24' '10.2.133.1/24'
# node_9505-1299                                
echo "adding cluster edge node_9505-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_1299' 'eth_1299_9505' '5' 'None' '10.1.28.2/24' '10.1.28.1/24'
# node_9505-23673                                
echo "adding host edge node_9505-23673"                                
sleep 0.2                                
funCreateV 'eth_9505_23673' 'eth_23673_9505' '5' '27' '10.2.1.2/24' '10.2.1.1/24'
# node_9505-2152                                
echo "adding cluster edge node_9505-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_2152' 'eth_2152_9505' '5' 'None' '10.1.71.2/24' '10.1.71.1/24'
# node_9957-23764                                
echo "adding host edge node_9957-23764"                                
sleep 0.2                                
funCreateV 'eth_9957_23764' 'eth_23764_9957' '6' '9' '10.3.91.2/24' '10.3.91.1/24'
# node_9957-4766                                
echo "adding cluster edge node_9957-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9957_4766' 'eth_4766_9957' '6' 'None' '10.2.246.2/24' '10.2.246.1/24'
# node_9957-3356                                
echo "adding cluster edge node_9957-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_9957_3356' 'eth_3356_9957' '6' 'None' '10.0.55.2/24' '10.0.55.1/24'
# node_9957-2914                                
echo "adding cluster edge node_9957-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9957_2914' 'eth_2914_9957' '6' 'None' '10.1.243.2/24' '10.1.243.1/24'
# node_9957-58453                                
echo "adding host edge node_9957-58453"                                
sleep 0.2                                
funCreateV 'eth_9957_58453' 'eth_58453_9957' '6' '18' '10.2.228.2/24' '10.2.228.1/24'
# node_4657-18106                                
echo "adding host edge node_4657-18106"                                
sleep 0.2                                
funCreateV 'eth_4657_18106' 'eth_18106_4657' '7' '23' '10.0.179.2/24' '10.0.179.1/24'
# node_4657-5511                                
echo "adding cluster edge node_4657-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_5511' 'eth_5511_4657' '7' 'None' '10.3.18.2/24' '10.3.18.1/24'
# node_4657-6453                                
echo "adding cluster edge node_4657-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_6453' 'eth_6453_4657' '7' 'None' '10.2.92.2/24' '10.2.92.1/24'
# node_4657-4134                                
echo "adding cluster edge node_4657-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_4134' 'eth_4134_4657' '7' 'None' '10.3.23.1/24' '10.3.23.2/24'
# node_4657-3786                                
echo "adding cluster edge node_4657-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_3786' 'eth_3786_4657' '7' 'None' '10.3.24.1/24' '10.3.24.2/24'
# node_4657-1299                                
echo "adding cluster edge node_4657-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_1299' 'eth_1299_4657' '7' 'None' '10.1.11.2/24' '10.1.11.1/24'
# node_4657-3462                                
echo "adding host edge node_4657-3462"                                
sleep 0.2                                
funCreateV 'eth_4657_3462' 'eth_3462_4657' '7' '17' '10.3.25.1/24' '10.3.25.2/24'
# node_4657-4637                                
echo "adding cluster edge node_4657-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_4637' 'eth_4637_4657' '7' 'None' '10.2.143.2/24' '10.2.143.1/24'
# node_4657-3356                                
echo "adding cluster edge node_4657-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_4657_3356' 'eth_3356_4657' '7' 'None' '10.0.56.2/24' '10.0.56.1/24'
# node_45974-3356                                
echo "adding cluster edge node_45974-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_45974_3356' 'eth_3356_45974' '8' 'None' '10.0.57.2/24' '10.0.57.1/24'
# node_45974-2914                                
echo "adding cluster edge node_45974-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_45974_2914' 'eth_2914_45974' '8' 'None' '10.1.244.2/24' '10.1.244.1/24'
# node_45974-9318                                
echo "adding host edge node_45974-9318"                                
sleep 0.2                                
funCreateV 'eth_45974_9318' 'eth_9318_45974' '8' '14' '10.3.164.2/24' '10.3.164.1/24'
# node_23764-23673                                
echo "adding host edge node_23764-23673"                                
sleep 0.2                                
funCreateV 'eth_23764_23673' 'eth_23673_23764' '9' '27' '10.1.246.2/24' '10.1.246.1/24'
# node_23764-2914                                
echo "adding cluster edge node_23764-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_2914' 'eth_2914_23764' '9' 'None' '10.1.203.2/24' '10.1.203.1/24'
# node_23764-6453                                
echo "adding cluster edge node_23764-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_6453' 'eth_6453_23764' '9' 'None' '10.2.94.2/24' '10.2.94.1/24'
# node_23764-9318                                
echo "adding host edge node_23764-9318"                                
sleep 0.2                                
funCreateV 'eth_23764_9318' 'eth_9318_23764' '9' '14' '10.3.92.1/24' '10.3.92.2/24'
# node_23764-4134                                
echo "adding cluster edge node_23764-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_4134' 'eth_4134_23764' '9' 'None' '10.3.69.2/24' '10.3.69.1/24'
# node_23764-3462                                
echo "adding host edge node_23764-3462"                                
sleep 0.2                                
funCreateV 'eth_23764_3462' 'eth_3462_23764' '9' '17' '10.3.93.1/24' '10.3.93.2/24'
# node_23764-7473                                
echo "adding host edge node_23764-7473"                                
sleep 0.2                                
funCreateV 'eth_23764_7473' 'eth_7473_23764' '9' '30' '10.2.235.2/24' '10.2.235.1/24'
# node_23764-37100                                
echo "adding cluster edge node_23764-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_37100' 'eth_37100_23764' '9' 'None' '10.2.51.2/24' '10.2.51.1/24'
# node_23764-4538                                
echo "adding host edge node_23764-4538"                                
sleep 0.2                                
funCreateV 'eth_23764_4538' 'eth_4538_23764' '9' '40' '10.3.94.1/24' '10.3.94.2/24'
# node_23764-1299                                
echo "adding cluster edge node_23764-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_1299' 'eth_1299_23764' '9' 'None' '10.1.19.2/24' '10.1.19.1/24'
# node_23764-3257                                
echo "adding cluster edge node_23764-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_3257' 'eth_3257_23764' '9' 'None' '10.0.145.2/24' '10.0.145.1/24'
# node_23764-3741                                
echo "adding cluster edge node_23764-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_3741' 'eth_3741_23764' '9' 'None' '10.0.173.2/24' '10.0.173.1/24'
# node_23764-18106                                
echo "adding host edge node_23764-18106"                                
sleep 0.2                                
funCreateV 'eth_23764_18106' 'eth_18106_23764' '9' '23' '10.0.198.2/24' '10.0.198.1/24'
# node_23764-174                                
echo "adding cluster edge node_23764-174"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_174' 'eth_174_23764' '9' 'None' '10.2.80.2/24' '10.2.80.1/24'
# node_23764-12552                                
echo "adding cluster edge node_23764-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_12552' 'eth_12552_23764' '9' 'None' '10.2.126.2/24' '10.2.126.1/24'
# node_23764-34224                                
echo "adding cluster edge node_23764-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_34224' 'eth_34224_23764' '9' 'None' '10.0.76.2/24' '10.0.76.1/24'
# node_23764-31133                                
echo "adding cluster edge node_23764-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_31133' 'eth_31133_23764' '9' 'None' '10.2.155.2/24' '10.2.155.1/24'
# node_23764-3303                                
echo "adding cluster edge node_23764-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_3303' 'eth_3303_23764' '9' 'None' '10.1.54.2/24' '10.1.54.1/24'
# node_23764-6939                                
echo "adding cluster edge node_23764-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_6939' 'eth_6939_23764' '9' 'None' '10.1.122.2/24' '10.1.122.1/24'
# node_23764-3491                                
echo "adding cluster edge node_23764-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_3491' 'eth_3491_23764' '9' 'None' '10.3.55.2/24' '10.3.55.1/24'
# node_23764-4809                                
echo "adding cluster edge node_23764-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_4809' 'eth_4809_23764' '9' 'None' '10.3.95.1/24' '10.3.95.2/24'
# node_23764-3356                                
echo "adding cluster edge node_23764-3356"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_3356' 'eth_3356_23764' '9' 'None' '10.0.58.2/24' '10.0.58.1/24'
# node_9304-37100                                
echo "adding cluster edge node_9304-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_37100' 'eth_37100_9304' '10' 'None' '10.2.36.2/24' '10.2.36.1/24'
# node_9304-2914                                
echo "adding cluster edge node_9304-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_2914' 'eth_2914_9304' '10' 'None' '10.1.195.2/24' '10.1.195.1/24'
# node_9304-6762                                
echo "adding cluster edge node_9304-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_6762' 'eth_6762_9304' '10' 'None' '10.2.163.1/24' '10.2.163.2/24'
# node_9304-15412                                
echo "adding host edge node_9304-15412"                                
sleep 0.2                                
funCreateV 'eth_9304_15412' 'eth_15412_9304' '10' '34' '10.2.164.1/24' '10.2.164.2/24'
# node_9304-12552                                
echo "adding cluster edge node_9304-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_12552' 'eth_12552_9304' '10' 'None' '10.2.115.2/24' '10.2.115.1/24'
# node_9304-34224                                
echo "adding cluster edge node_9304-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_34224' 'eth_34224_9304' '10' 'None' '10.0.61.2/24' '10.0.61.1/24'
# node_9304-3303                                
echo "adding cluster edge node_9304-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_3303' 'eth_3303_9304' '10' 'None' '10.1.30.2/24' '10.1.30.1/24'
# node_9304-1239                                
echo "adding cluster edge node_9304-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_1239' 'eth_1239_9304' '10' 'None' '10.2.14.2/24' '10.2.14.1/24'
# node_9304-2497                                
echo "adding cluster edge node_9304-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_2497' 'eth_2497_9304' '10' 'None' '10.1.141.2/24' '10.1.141.1/24'
# node_9304-4809                                
echo "adding cluster edge node_9304-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_4809' 'eth_4809_9304' '10' 'None' '10.2.166.1/24' '10.2.166.2/24'
# node_9304-9318                                
echo "adding host edge node_9304-9318"                                
sleep 0.2                                
funCreateV 'eth_9304_9318' 'eth_9318_9304' '10' '14' '10.2.168.1/24' '10.2.168.2/24'
# node_4651-37100                                
echo "adding cluster edge node_4651-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_37100' 'eth_37100_4651' '11' 'None' '10.2.37.2/24' '10.2.37.1/24'
# node_4651-4766                                
echo "adding cluster edge node_4651-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_4766' 'eth_4766_4651' '11' 'None' '10.2.238.1/24' '10.2.238.2/24'
# node_4651-6939                                
echo "adding cluster edge node_4651-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_6939' 'eth_6939_4651' '11' 'None' '10.1.87.2/24' '10.1.87.1/24'
# node_4651-3741                                
echo "adding cluster edge node_4651-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_3741' 'eth_3741_4651' '11' 'None' '10.0.162.2/24' '10.0.162.1/24'
# node_4651-34224                                
echo "adding cluster edge node_4651-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_34224' 'eth_34224_4651' '11' 'None' '10.0.63.2/24' '10.0.63.1/24'
# node_4651-2914                                
echo "adding cluster edge node_4651-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_2914' 'eth_2914_4651' '11' 'None' '10.1.199.2/24' '10.1.199.1/24'
# node_4651-3303                                
echo "adding cluster edge node_4651-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_3303' 'eth_3303_4651' '11' 'None' '10.1.33.2/24' '10.1.33.1/24'
# node_4651-1273                                
echo "adding cluster edge node_4651-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_1273' 'eth_1273_4651' '11' 'None' '10.2.239.1/24' '10.2.239.2/24'
# node_4651-3491                                
echo "adding cluster edge node_4651-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_3491' 'eth_3491_4651' '11' 'None' '10.2.240.1/24' '10.2.240.2/24'
# node_4651-18106                                
echo "adding host edge node_4651-18106"                                
sleep 0.2                                
funCreateV 'eth_4651_18106' 'eth_18106_4651' '11' '23' '10.0.190.2/24' '10.0.190.1/24'
# node_4651-9002                                
echo "adding cluster edge node_4651-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_9002' 'eth_9002_4651' '11' 'None' '10.2.241.1/24' '10.2.241.2/24'
# node_4651-2497                                
echo "adding cluster edge node_4651-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_2497' 'eth_2497_4651' '11' 'None' '10.1.156.2/24' '10.1.156.1/24'
# node_4651-174                                
echo "adding cluster edge node_4651-174"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_174' 'eth_174_4651' '11' 'None' '10.2.71.2/24' '10.2.71.1/24'
# node_4651-6453                                
echo "adding cluster edge node_4651-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_6453' 'eth_6453_4651' '11' 'None' '10.2.110.2/24' '10.2.110.1/24'
# node_4651-4637                                
echo "adding cluster edge node_4651-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_4637' 'eth_4637_4651' '11' 'None' '10.2.145.2/24' '10.2.145.1/24'
# node_702-5413                                
echo "adding cluster edge node_702-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_702_5413' 'eth_5413_702' '12' 'None' '10.1.186.2/24' '10.1.186.1/24'
# node_702-4837                                
echo "adding cluster edge node_702-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_702_4837' 'eth_4837_702' '12' 'None' '10.3.11.2/24' '10.3.11.1/24'
# node_702-12552                                
echo "adding cluster edge node_702-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_702_12552' 'eth_12552_702' '12' 'None' '10.2.116.2/24' '10.2.116.1/24'
# node_702-34224                                
echo "adding cluster edge node_702-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_702_34224' 'eth_34224_702' '12' 'None' '10.0.65.2/24' '10.0.65.1/24'
# node_4788-37100                                
echo "adding cluster edge node_4788-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_37100' 'eth_37100_4788' '13' 'None' '10.2.44.2/24' '10.2.44.1/24'
# node_4788-6453                                
echo "adding cluster edge node_4788-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_6453' 'eth_6453_4788' '13' 'None' '10.2.98.2/24' '10.2.98.1/24'
# node_4788-6939                                
echo "adding cluster edge node_4788-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_6939' 'eth_6939_4788' '13' 'None' '10.1.94.2/24' '10.1.94.1/24'
# node_4788-1299                                
echo "adding cluster edge node_4788-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_1299' 'eth_1299_4788' '13' 'None' '10.1.2.2/24' '10.1.2.1/24'
# node_4788-3741                                
echo "adding cluster edge node_4788-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_3741' 'eth_3741_4788' '13' 'None' '10.0.169.2/24' '10.0.169.1/24'
# node_4788-34224                                
echo "adding cluster edge node_4788-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_34224' 'eth_34224_4788' '13' 'None' '10.0.66.2/24' '10.0.66.1/24'
# node_4788-2497                                
echo "adding cluster edge node_4788-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_2497' 'eth_2497_4788' '13' 'None' '10.1.150.2/24' '10.1.150.1/24'
# node_4788-3303                                
echo "adding cluster edge node_4788-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_3303' 'eth_3303_4788' '13' 'None' '10.1.41.2/24' '10.1.41.1/24'
# node_4788-2914                                
echo "adding cluster edge node_4788-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_2914' 'eth_2914_4788' '13' 'None' '10.1.211.2/24' '10.1.211.1/24'
# node_4788-174                                
echo "adding cluster edge node_4788-174"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_174' 'eth_174_4788' '13' 'None' '10.2.64.2/24' '10.2.64.1/24'
# node_4788-5413                                
echo "adding cluster edge node_4788-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_5413' 'eth_5413_4788' '13' 'None' '10.1.188.2/24' '10.1.188.1/24'
# node_4788-293                                
echo "adding cluster edge node_4788-293"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_293' 'eth_293_4788' '13' 'None' '10.1.174.2/24' '10.1.174.1/24'
# node_4788-15932                                
echo "adding host edge node_4788-15932"                                
sleep 0.2                                
funCreateV 'eth_4788_15932' 'eth_15932_4788' '13' '39' '10.3.121.1/24' '10.3.121.2/24'
# node_9318-1299                                
echo "adding cluster edge node_9318-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_1299' 'eth_1299_9318' '14' 'None' '10.1.4.2/24' '10.1.4.1/24'
# node_9318-12552                                
echo "adding cluster edge node_9318-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_12552' 'eth_12552_9318' '14' 'None' '10.2.120.2/24' '10.2.120.1/24'
# node_9318-2914                                
echo "adding cluster edge node_9318-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_2914' 'eth_2914_9318' '14' 'None' '10.1.214.2/24' '10.1.214.1/24'
# node_9318-701                                
echo "adding cluster edge node_9318-701"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_701' 'eth_701_9318' '14' 'None' '10.3.154.1/24' '10.3.154.2/24'
# node_9318-174                                
echo "adding cluster edge node_9318-174"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_174' 'eth_174_9318' '14' 'None' '10.2.66.2/24' '10.2.66.1/24'
# node_9318-18106                                
echo "adding host edge node_9318-18106"                                
sleep 0.2                                
funCreateV 'eth_9318_18106' 'eth_18106_9318' '14' '23' '10.0.186.2/24' '10.0.186.1/24'
# node_9318-6461                                
echo "adding cluster edge node_9318-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_6461' 'eth_6461_9318' '14' 'None' '10.2.186.2/24' '10.2.186.1/24'
# node_9318-34224                                
echo "adding cluster edge node_9318-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_34224' 'eth_34224_9318' '14' 'None' '10.0.67.2/24' '10.0.67.1/24'
# node_9318-20764                                
echo "adding host edge node_9318-20764"                                
sleep 0.2                                
funCreateV 'eth_9318_20764' 'eth_20764_9318' '14' '43' '10.3.118.2/24' '10.3.118.1/24'
# node_9318-3303                                
echo "adding cluster edge node_9318-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_3303' 'eth_3303_9318' '14' 'None' '10.1.44.2/24' '10.1.44.1/24'
# node_9318-6939                                
echo "adding cluster edge node_9318-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_6939' 'eth_6939_9318' '14' 'None' '10.1.98.2/24' '10.1.98.1/24'
# node_9318-2152                                
echo "adding cluster edge node_9318-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_2152' 'eth_2152_9318' '14' 'None' '10.1.65.2/24' '10.1.65.1/24'
# node_9318-2497                                
echo "adding cluster edge node_9318-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_2497' 'eth_2497_9318' '14' 'None' '10.1.152.2/24' '10.1.152.1/24'
# node_9318-1239                                
echo "adding cluster edge node_9318-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_1239' 'eth_1239_9318' '14' 'None' '10.2.23.2/24' '10.2.23.1/24'
# node_9318-37100                                
echo "adding cluster edge node_9318-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_37100' 'eth_37100_9318' '14' 'None' '10.2.46.2/24' '10.2.46.1/24'
# node_9318-3741                                
echo "adding cluster edge node_9318-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_3741' 'eth_3741_9318' '14' 'None' '10.0.170.2/24' '10.0.170.1/24'
# node_9318-31133                                
echo "adding cluster edge node_9318-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_31133' 'eth_31133_9318' '14' 'None' '10.2.151.2/24' '10.2.151.1/24'
# node_9318-4766                                
echo "adding cluster edge node_9318-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_4766' 'eth_4766_9318' '14' 'None' '10.2.254.2/24' '10.2.254.1/24'
# node_9318-3786                                
echo "adding cluster edge node_9318-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_3786' 'eth_3786_9318' '14' 'None' '10.3.137.2/24' '10.3.137.1/24'
# node_8763-24785                                
echo "adding host edge node_8763-24785"                                
sleep 0.2                                
funCreateV 'eth_8763_24785' 'eth_24785_8763' '15' '36' '10.3.194.1/24' '10.3.194.2/24'
# node_8763-12552                                
echo "adding cluster edge node_8763-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_12552' 'eth_12552_8763' '15' 'None' '10.2.122.2/24' '10.2.122.1/24'
# node_8763-34224                                
echo "adding cluster edge node_8763-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_34224' 'eth_34224_8763' '15' 'None' '10.0.69.2/24' '10.0.69.1/24'
# node_8763-31133                                
echo "adding cluster edge node_8763-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_31133' 'eth_31133_8763' '15' 'None' '10.2.152.2/24' '10.2.152.1/24'
# node_8763-6939                                
echo "adding cluster edge node_8763-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_6939' 'eth_6939_8763' '15' 'None' '10.1.104.2/24' '10.1.104.1/24'
# node_8763-3303                                
echo "adding cluster edge node_8763-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_3303' 'eth_3303_8763' '15' 'None' '10.1.48.2/24' '10.1.48.1/24'
# node_9498-37100                                
echo "adding cluster edge node_9498-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_37100' 'eth_37100_9498' '16' 'None' '10.2.48.2/24' '10.2.48.1/24'
# node_9498-55410                                
echo "adding cluster edge node_9498-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_55410' 'eth_55410_9498' '16' 'None' '10.3.176.2/24' '10.3.176.1/24'
# node_9498-6453                                
echo "adding cluster edge node_9498-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_6453' 'eth_6453_9498' '16' 'None' '10.2.100.2/24' '10.2.100.1/24'
# node_9498-6461                                
echo "adding cluster edge node_9498-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_6461' 'eth_6461_9498' '16' 'None' '10.2.190.2/24' '10.2.190.1/24'
# node_9498-12552                                
echo "adding cluster edge node_9498-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_12552' 'eth_12552_9498' '16' 'None' '10.2.123.2/24' '10.2.123.1/24'
# node_9498-3257                                
echo "adding cluster edge node_9498-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_3257' 'eth_3257_9498' '16' 'None' '10.0.142.2/24' '10.0.142.1/24'
# node_9498-4637                                
echo "adding cluster edge node_9498-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_4637' 'eth_4637_9498' '16' 'None' '10.2.139.2/24' '10.2.139.1/24'
# node_9498-2914                                
echo "adding cluster edge node_9498-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_2914' 'eth_2914_9498' '16' 'None' '10.1.223.2/24' '10.1.223.1/24'
# node_9498-31133                                
echo "adding cluster edge node_9498-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_31133' 'eth_31133_9498' '16' 'None' '10.2.153.2/24' '10.2.153.1/24'
# node_9498-34224                                
echo "adding cluster edge node_9498-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_34224' 'eth_34224_9498' '16' 'None' '10.0.70.2/24' '10.0.70.1/24'
# node_9498-18106                                
echo "adding host edge node_9498-18106"                                
sleep 0.2                                
funCreateV 'eth_9498_18106' 'eth_18106_9498' '16' '23' '10.0.191.2/24' '10.0.191.1/24'
# node_9498-23673                                
echo "adding host edge node_9498-23673"                                
sleep 0.2                                
funCreateV 'eth_9498_23673' 'eth_23673_9498' '16' '27' '10.1.251.2/24' '10.1.251.1/24'
# node_9498-1299                                
echo "adding cluster edge node_9498-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_1299' 'eth_1299_9498' '16' 'None' '10.1.9.2/24' '10.1.9.1/24'
# node_9498-3303                                
echo "adding cluster edge node_9498-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_3303' 'eth_3303_9498' '16' 'None' '10.1.51.2/24' '10.1.51.1/24'
# node_9498-3491                                
echo "adding cluster edge node_9498-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_3491' 'eth_3491_9498' '16' 'None' '10.3.48.2/24' '10.3.48.1/24'
# node_9498-6939                                
echo "adding cluster edge node_9498-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_6939' 'eth_6939_9498' '16' 'None' '10.1.107.2/24' '10.1.107.1/24'
# node_9498-2497                                
echo "adding cluster edge node_9498-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_2497' 'eth_2497_9498' '16' 'None' '10.1.159.2/24' '10.1.159.1/24'
# node_9498-174                                
echo "adding cluster edge node_9498-174"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_174' 'eth_174_9498' '16' 'None' '10.2.72.2/24' '10.2.72.1/24'
# node_9498-55644                                
echo "adding cluster edge node_9498-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_55644' 'eth_55644_9498' '16' 'None' '10.3.203.1/24' '10.3.203.2/24'
# node_3462-9680                                
echo "adding cluster edge node_3462-9680"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_9680' 'eth_9680_3462' '17' 'None' '10.3.206.1/24' '10.3.206.2/24'
# node_3462-2914                                
echo "adding cluster edge node_3462-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_2914' 'eth_2914_3462' '17' 'None' '10.1.228.2/24' '10.1.228.1/24'
# node_3462-2497                                
echo "adding cluster edge node_3462-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_2497' 'eth_2497_3462' '17' 'None' '10.1.161.2/24' '10.1.161.1/24'
# node_3462-6939                                
echo "adding cluster edge node_3462-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_6939' 'eth_6939_3462' '17' 'None' '10.1.115.2/24' '10.1.115.1/24'
# node_3462-34224                                
echo "adding cluster edge node_3462-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_34224' 'eth_34224_3462' '17' 'None' '10.0.73.2/24' '10.0.73.1/24'
# node_3462-3741                                
echo "adding cluster edge node_3462-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_3741' 'eth_3741_3462' '17' 'None' '10.0.172.2/24' '10.0.172.1/24'
# node_3462-1239                                
echo "adding cluster edge node_3462-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_1239' 'eth_1239_3462' '17' 'None' '10.2.28.2/24' '10.2.28.1/24'
# node_3462-37100                                
echo "adding cluster edge node_3462-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_37100' 'eth_37100_3462' '17' 'None' '10.2.49.2/24' '10.2.49.1/24'
# node_3462-12552                                
echo "adding cluster edge node_3462-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_12552' 'eth_12552_3462' '17' 'None' '10.2.125.2/24' '10.2.125.1/24'
# node_58453-3257                                
echo "adding cluster edge node_58453-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_3257' 'eth_3257_58453' '18' 'None' '10.0.128.2/24' '10.0.128.1/24'
# node_58453-38040                                
echo "adding cluster edge node_58453-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_38040' 'eth_38040_58453' '18' 'None' '10.2.217.2/24' '10.2.217.1/24'
# node_58453-2914                                
echo "adding cluster edge node_58453-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_2914' 'eth_2914_58453' '18' 'None' '10.1.221.2/24' '10.1.221.1/24'
# node_58453-4538                                
echo "adding host edge node_58453-4538"                                
sleep 0.2                                
funCreateV 'eth_58453_4538' 'eth_4538_58453' '18' '40' '10.2.224.1/24' '10.2.224.2/24'
# node_58453-34224                                
echo "adding cluster edge node_58453-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_34224' 'eth_34224_58453' '18' 'None' '10.0.75.2/24' '10.0.75.1/24'
# node_58453-31133                                
echo "adding cluster edge node_58453-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_31133' 'eth_31133_58453' '18' 'None' '10.2.154.2/24' '10.2.154.1/24'
# node_58453-1239                                
echo "adding cluster edge node_58453-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_1239' 'eth_1239_58453' '18' 'None' '10.2.31.2/24' '10.2.31.1/24'
# node_58453-1299                                
echo "adding cluster edge node_58453-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_1299' 'eth_1299_58453' '18' 'None' '10.1.21.2/24' '10.1.21.1/24'
# node_58453-18403                                
echo "adding cluster edge node_58453-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_18403' 'eth_18403_58453' '18' 'None' '10.2.225.1/24' '10.2.225.2/24'
# node_58453-12552                                
echo "adding cluster edge node_58453-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_12552' 'eth_12552_58453' '18' 'None' '10.2.128.2/24' '10.2.128.1/24'
# node_58453-3303                                
echo "adding cluster edge node_58453-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_3303' 'eth_3303_58453' '18' 'None' '10.1.55.2/24' '10.1.55.1/24'
# node_58453-2497                                
echo "adding cluster edge node_58453-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_2497' 'eth_2497_58453' '18' 'None' '10.1.167.2/24' '10.1.167.1/24'
# node_58453-23673                                
echo "adding host edge node_58453-23673"                                
sleep 0.2                                
funCreateV 'eth_58453_23673' 'eth_23673_58453' '18' '27' '10.2.2.2/24' '10.2.2.1/24'
# node_58453-174                                
echo "adding cluster edge node_58453-174"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_174' 'eth_174_58453' '18' 'None' '10.2.84.2/24' '10.2.84.1/24'
# node_9605-2497                                
echo "adding cluster edge node_9605-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_2497' 'eth_2497_9605' '19' 'None' '10.1.165.2/24' '10.1.165.1/24'
# node_9605-2914                                
echo "adding cluster edge node_9605-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_2914' 'eth_2914_9605' '19' 'None' '10.1.235.2/24' '10.1.235.1/24'
# node_9605-6939                                
echo "adding cluster edge node_9605-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_6939' 'eth_6939_9605' '19' 'None' '10.1.124.2/24' '10.1.124.1/24'
# node_9605-12552                                
echo "adding cluster edge node_9605-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_12552' 'eth_12552_9605' '19' 'None' '10.2.129.2/24' '10.2.129.1/24'
# node_9605-34224                                
echo "adding cluster edge node_9605-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_34224' 'eth_34224_9605' '19' 'None' '10.0.78.2/24' '10.0.78.1/24'
# node_9605-18106                                
echo "adding host edge node_9605-18106"                                
sleep 0.2                                
funCreateV 'eth_9605_18106' 'eth_18106_9605' '19' '23' '10.0.201.2/24' '10.0.201.1/24'
# node_9605-1239                                
echo "adding cluster edge node_9605-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_1239' 'eth_1239_9605' '19' 'None' '10.2.32.2/24' '10.2.32.1/24'
# node_9605-293                                
echo "adding cluster edge node_9605-293"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_293' 'eth_293_9605' '19' 'None' '10.1.180.2/24' '10.1.180.1/24'
# node_9605-20485                                
echo "adding host edge node_9605-20485"                                
sleep 0.2                                
funCreateV 'eth_9605_20485' 'eth_20485_9605' '19' '45' '10.3.33.2/24' '10.3.33.1/24'
# node_10158-3491                                
echo "adding cluster edge node_10158-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_10158_3491' 'eth_3491_10158' '20' 'None' '10.3.59.2/24' '10.3.59.1/24'
# node_10158-15412                                
echo "adding host edge node_10158-15412"                                
sleep 0.2                                
funCreateV 'eth_10158_15412' 'eth_15412_10158' '20' '34' '10.2.181.2/24' '10.2.181.1/24'
# node_10158-18106                                
echo "adding host edge node_10158-18106"                                
sleep 0.2                                
funCreateV 'eth_10158_18106' 'eth_18106_10158' '20' '23' '10.0.207.2/24' '10.0.207.1/24'
# node_10158-12552                                
echo "adding cluster edge node_10158-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_10158_12552' 'eth_12552_10158' '20' 'None' '10.2.134.2/24' '10.2.134.1/24'
# node_10158-34224                                
echo "adding cluster edge node_10158-34224"                                
sleep 0.2                                
funCreateClusterV 'eth_10158_34224' 'eth_34224_10158' '20' 'None' '10.0.81.2/24' '10.0.81.1/24'
# node_10158-31133                                
echo "adding cluster edge node_10158-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_10158_31133' 'eth_31133_10158' '20' 'None' '10.2.157.2/24' '10.2.157.1/24'
# node_10158-23673                                
echo "adding host edge node_10158-23673"                                
sleep 0.2                                
funCreateV 'eth_10158_23673' 'eth_23673_10158' '20' '27' '10.2.3.2/24' '10.2.3.1/24'
# node_20912-13335                                
echo "adding cluster edge node_20912-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_20912_13335' 'eth_13335_20912' '21' 'None' '10.0.83.2/24' '10.0.83.1/24'
# node_20912-6939                                
echo "adding cluster edge node_20912-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_20912_6939' 'eth_6939_20912' '21' 'None' '10.0.121.1/24' '10.0.121.2/24'
# node_20912-3257                                
echo "adding cluster edge node_20912-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_20912_3257' 'eth_3257_20912' '21' 'None' '10.0.122.1/24' '10.0.122.2/24'
# node_49788-13335                                
echo "adding cluster edge node_49788-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_49788_13335' 'eth_13335_49788' '22' 'None' '10.0.85.2/24' '10.0.85.1/24'
# node_49788-6939                                
echo "adding cluster edge node_49788-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_49788_6939' 'eth_6939_49788' '22' 'None' '10.0.155.1/24' '10.0.155.2/24'
# node_49788-12552                                
echo "adding cluster edge node_49788-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_49788_12552' 'eth_12552_49788' '22' 'None' '10.0.156.1/24' '10.0.156.2/24'
# node_49788-1299                                
echo "adding cluster edge node_49788-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_49788_1299' 'eth_1299_49788' '22' 'None' '10.0.157.1/24' '10.0.157.2/24'
# node_49788-174                                
echo "adding cluster edge node_49788-174"                                
sleep 0.2                                
funCreateClusterV 'eth_49788_174' 'eth_174_49788' '22' 'None' '10.0.158.1/24' '10.0.158.2/24'
# node_18106-13335                                
echo "adding cluster edge node_18106-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_13335' 'eth_13335_18106' '23' 'None' '10.0.87.2/24' '10.0.87.1/24'
# node_18106-6939                                
echo "adding cluster edge node_18106-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_6939' 'eth_6939_18106' '23' 'None' '10.0.175.1/24' '10.0.175.2/24'
# node_18106-2519                                
echo "adding cluster edge node_18106-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_2519' 'eth_2519_18106' '23' 'None' '10.0.176.1/24' '10.0.176.2/24'
# node_18106-15412                                
echo "adding host edge node_18106-15412"                                
sleep 0.2                                
funCreateV 'eth_18106_15412' 'eth_15412_18106' '23' '34' '10.0.177.1/24' '10.0.177.2/24'
# node_18106-38040                                
echo "adding cluster edge node_18106-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_38040' 'eth_38040_18106' '23' 'None' '10.0.178.1/24' '10.0.178.2/24'
# node_18106-17676                                
echo "adding host edge node_18106-17676"                                
sleep 0.2                                
funCreateV 'eth_18106_17676' 'eth_17676_18106' '23' '29' '10.0.181.1/24' '10.0.181.2/24'
# node_18106-9583                                
echo "adding host edge node_18106-9583"                                
sleep 0.2                                
funCreateV 'eth_18106_9583' 'eth_9583_18106' '23' '35' '10.0.182.1/24' '10.0.182.2/24'
# node_18106-2914                                
echo "adding cluster edge node_18106-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_2914' 'eth_2914_18106' '23' 'None' '10.0.183.1/24' '10.0.183.2/24'
# node_18106-64049                                
echo "adding cluster edge node_18106-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_64049' 'eth_64049_18106' '23' 'None' '10.0.184.1/24' '10.0.184.2/24'
# node_18106-132203                                
echo "adding cluster edge node_18106-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_132203' 'eth_132203_18106' '23' 'None' '10.0.187.1/24' '10.0.187.2/24'
# node_18106-174                                
echo "adding cluster edge node_18106-174"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_174' 'eth_174_18106' '23' 'None' '10.0.188.1/24' '10.0.188.2/24'
# node_18106-33891                                
echo "adding cluster edge node_18106-33891"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_33891' 'eth_33891_18106' '23' 'None' '10.0.189.1/24' '10.0.189.2/24'
# node_18106-64050                                
echo "adding host edge node_18106-64050"                                
sleep 0.2                                
funCreateV 'eth_18106_64050' 'eth_64050_18106' '23' '37' '10.0.192.1/24' '10.0.192.2/24'
# node_18106-9002                                
echo "adding cluster edge node_18106-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_9002' 'eth_9002_18106' '23' 'None' '10.0.193.1/24' '10.0.193.2/24'
# node_18106-4775                                
echo "adding cluster edge node_18106-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_4775' 'eth_4775_18106' '23' 'None' '10.0.194.1/24' '10.0.194.2/24'
# node_18106-16509                                
echo "adding cluster edge node_18106-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_16509' 'eth_16509_18106' '23' 'None' '10.0.195.1/24' '10.0.195.2/24'
# node_18106-15932                                
echo "adding host edge node_18106-15932"                                
sleep 0.2                                
funCreateV 'eth_18106_15932' 'eth_15932_18106' '23' '39' '10.0.196.1/24' '10.0.196.2/24'
# node_18106-10089                                
echo "adding host edge node_18106-10089"                                
sleep 0.2                                
funCreateV 'eth_18106_10089' 'eth_10089_18106' '23' '38' '10.0.197.1/24' '10.0.197.2/24'
# node_18106-18403                                
echo "adding cluster edge node_18106-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_18403' 'eth_18403_18106' '23' 'None' '10.0.199.1/24' '10.0.199.2/24'
# node_18106-2497                                
echo "adding cluster edge node_18106-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_2497' 'eth_2497_18106' '23' 'None' '10.0.200.1/24' '10.0.200.2/24'
# node_18106-4809                                
echo "adding cluster edge node_18106-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_4809' 'eth_4809_18106' '23' 'None' '10.0.202.1/24' '10.0.202.2/24'
# node_18106-4826                                
echo "adding host edge node_18106-4826"                                
sleep 0.2                                
funCreateV 'eth_18106_4826' 'eth_4826_18106' '23' '41' '10.0.203.1/24' '10.0.203.2/24'
# node_11686-13335                                
echo "adding cluster edge node_11686-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_11686_13335' 'eth_13335_11686' '24' 'None' '10.0.88.2/24' '10.0.88.1/24'
# node_11686-6939                                
echo "adding cluster edge node_11686-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_11686_6939' 'eth_6939_11686' '24' 'None' '10.0.208.1/24' '10.0.208.2/24'
# node_11686-174                                
echo "adding cluster edge node_11686-174"                                
sleep 0.2                                
funCreateClusterV 'eth_11686_174' 'eth_174_11686' '24' 'None' '10.0.209.1/24' '10.0.209.2/24'
# node_11686-6461                                
echo "adding cluster edge node_11686-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_11686_6461' 'eth_6461_11686' '24' 'None' '10.0.210.1/24' '10.0.210.2/24'
# node_11686-16509                                
echo "adding cluster edge node_11686-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_11686_16509' 'eth_16509_11686' '24' 'None' '10.0.211.1/24' '10.0.211.2/24'
# node_22652-13335                                
echo "adding cluster edge node_22652-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_13335' 'eth_13335_22652' '25' 'None' '10.0.89.2/24' '10.0.89.1/24'
# node_22652-6939                                
echo "adding cluster edge node_22652-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_6939' 'eth_6939_22652' '25' 'None' '10.0.213.1/24' '10.0.213.2/24'
# node_22652-1299                                
echo "adding cluster edge node_22652-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_1299' 'eth_1299_22652' '25' 'None' '10.0.214.1/24' '10.0.214.2/24'
# node_22652-6453                                
echo "adding cluster edge node_22652-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_6453' 'eth_6453_22652' '25' 'None' '10.0.215.1/24' '10.0.215.2/24'
# node_22652-174                                
echo "adding cluster edge node_22652-174"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_174' 'eth_174_22652' '25' 'None' '10.0.216.1/24' '10.0.216.2/24'
# node_22652-64049                                
echo "adding cluster edge node_22652-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_64049' 'eth_64049_22652' '25' 'None' '10.0.217.1/24' '10.0.217.2/24'
# node_22652-33891                                
echo "adding cluster edge node_22652-33891"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_33891' 'eth_33891_22652' '25' 'None' '10.0.218.1/24' '10.0.218.2/24'
# node_22652-3257                                
echo "adding cluster edge node_22652-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_22652_3257' 'eth_3257_22652' '25' 'None' '10.0.143.2/24' '10.0.143.1/24'
# node_8492-13335                                
echo "adding cluster edge node_8492-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_13335' 'eth_13335_8492' '26' 'None' '10.0.91.2/24' '10.0.91.1/24'
# node_8492-6939                                
echo "adding cluster edge node_8492-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_6939' 'eth_6939_8492' '26' 'None' '10.0.227.1/24' '10.0.227.2/24'
# node_8492-31133                                
echo "adding cluster edge node_8492-31133"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_31133' 'eth_31133_8492' '26' 'None' '10.0.228.1/24' '10.0.228.2/24'
# node_8492-38040                                
echo "adding cluster edge node_8492-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_38040' 'eth_38040_8492' '26' 'None' '10.0.230.1/24' '10.0.230.2/24'
# node_8492-20485                                
echo "adding host edge node_8492-20485"                                
sleep 0.2                                
funCreateV 'eth_8492_20485' 'eth_20485_8492' '26' '45' '10.0.231.1/24' '10.0.231.2/24'
# node_8492-20764                                
echo "adding host edge node_8492-20764"                                
sleep 0.2                                
funCreateV 'eth_8492_20764' 'eth_20764_8492' '26' '43' '10.0.233.1/24' '10.0.233.2/24'
# node_23673-13335                                
echo "adding cluster edge node_23673-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_13335' 'eth_13335_23673' '27' 'None' '10.0.99.2/24' '10.0.99.1/24'
# node_23673-6939                                
echo "adding cluster edge node_23673-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_6939' 'eth_6939_23673' '27' 'None' '10.1.82.2/24' '10.1.82.1/24'
# node_23673-9583                                
echo "adding host edge node_23673-9583"                                
sleep 0.2                                
funCreateV 'eth_23673_9583' 'eth_9583_23673' '27' '35' '10.1.247.1/24' '10.1.247.2/24'
# node_23673-64049                                
echo "adding cluster edge node_23673-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_64049' 'eth_64049_23673' '27' 'None' '10.1.248.1/24' '10.1.248.2/24'
# node_23673-132203                                
echo "adding cluster edge node_23673-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_132203' 'eth_132203_23673' '27' 'None' '10.1.249.1/24' '10.1.249.2/24'
# node_23673-33891                                
echo "adding cluster edge node_23673-33891"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_33891' 'eth_33891_23673' '27' 'None' '10.1.250.1/24' '10.1.250.2/24'
# node_23673-64050                                
echo "adding host edge node_23673-64050"                                
sleep 0.2                                
funCreateV 'eth_23673_64050' 'eth_64050_23673' '27' '37' '10.1.252.1/24' '10.1.252.2/24'
# node_23673-16509                                
echo "adding cluster edge node_23673-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_16509' 'eth_16509_23673' '27' 'None' '10.1.253.1/24' '10.1.253.2/24'
# node_23673-18403                                
echo "adding cluster edge node_23673-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_18403' 'eth_18403_23673' '27' 'None' '10.1.254.1/24' '10.1.254.2/24'
# node_1403-13335                                
echo "adding cluster edge node_1403-13335"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_13335' 'eth_13335_1403' '28' 'None' '10.0.100.2/24' '10.0.100.1/24'
# node_1403-6939                                
echo "adding cluster edge node_1403-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_6939' 'eth_6939_1403' '28' 'None' '10.1.79.2/24' '10.1.79.1/24'
# node_1403-1299                                
echo "adding cluster edge node_1403-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_1299' 'eth_1299_1403' '28' 'None' '10.0.238.2/24' '10.0.238.1/24'
# node_1403-6453                                
echo "adding cluster edge node_1403-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_6453' 'eth_6453_1403' '28' 'None' '10.2.5.1/24' '10.2.5.2/24'
# node_1403-6461                                
echo "adding cluster edge node_1403-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_6461' 'eth_6461_1403' '28' 'None' '10.2.6.1/24' '10.2.6.2/24'
# node_1403-174                                
echo "adding cluster edge node_1403-174"                                
sleep 0.2                                
funCreateClusterV 'eth_1403_174' 'eth_174_1403' '28' 'None' '10.2.7.1/24' '10.2.7.2/24'
# node_17676-3257                                
echo "adding cluster edge node_17676-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_3257' 'eth_3257_17676' '29' 'None' '10.0.132.2/24' '10.0.132.1/24'
# node_17676-1239                                
echo "adding cluster edge node_17676-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_1239' 'eth_1239_17676' '29' 'None' '10.2.18.2/24' '10.2.18.1/24'
# node_17676-1299                                
echo "adding cluster edge node_17676-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_1299' 'eth_1299_17676' '29' 'None' '10.0.246.2/24' '10.0.246.1/24'
# node_17676-6461                                
echo "adding cluster edge node_17676-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_6461' 'eth_6461_17676' '29' 'None' '10.2.184.2/24' '10.2.184.1/24'
# node_17676-6453                                
echo "adding cluster edge node_17676-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_6453' 'eth_6453_17676' '29' 'None' '10.2.89.2/24' '10.2.89.1/24'
# node_17676-20485                                
echo "adding host edge node_17676-20485"                                
sleep 0.2                                
funCreateV 'eth_17676_20485' 'eth_20485_17676' '29' '45' '10.3.27.2/24' '10.3.27.1/24'
# node_17676-2914                                
echo "adding cluster edge node_17676-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_2914' 'eth_2914_17676' '29' 'None' '10.1.202.2/24' '10.1.202.1/24'
# node_17676-3303                                
echo "adding cluster edge node_17676-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_3303' 'eth_3303_17676' '29' 'None' '10.1.36.2/24' '10.1.36.1/24'
# node_17676-2497                                
echo "adding cluster edge node_17676-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_2497' 'eth_2497_17676' '29' 'None' '10.1.148.2/24' '10.1.148.1/24'
# node_17676-64050                                
echo "adding host edge node_17676-64050"                                
sleep 0.2                                
funCreateV 'eth_17676_64050' 'eth_64050_17676' '29' '37' '10.3.90.1/24' '10.3.90.2/24'
# node_17676-6939                                
echo "adding cluster edge node_17676-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_6939' 'eth_6939_17676' '29' 'None' '10.1.126.2/24' '10.1.126.1/24'
# node_7473-6461                                
echo "adding cluster edge node_7473-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_6461' 'eth_6461_7473' '30' 'None' '10.2.182.2/24' '10.2.182.1/24'
# node_7473-38040                                
echo "adding cluster edge node_7473-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_38040' 'eth_38040_7473' '30' 'None' '10.2.218.2/24' '10.2.218.1/24'
# node_7473-1299                                
echo "adding cluster edge node_7473-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_1299' 'eth_1299_7473' '30' 'None' '10.0.242.2/24' '10.0.242.1/24'
# node_7473-9583                                
echo "adding host edge node_7473-9583"                                
sleep 0.2                                
funCreateV 'eth_7473_9583' 'eth_9583_7473' '30' '35' '10.2.230.1/24' '10.2.230.2/24'
# node_7473-3303                                
echo "adding cluster edge node_7473-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_3303' 'eth_3303_7473' '30' 'None' '10.1.39.2/24' '10.1.39.1/24'
# node_7473-6453                                
echo "adding cluster edge node_7473-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_6453' 'eth_6453_7473' '30' 'None' '10.2.97.2/24' '10.2.97.1/24'
# node_7473-1273                                
echo "adding cluster edge node_7473-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_1273' 'eth_1273_7473' '30' 'None' '10.2.231.1/24' '10.2.231.2/24'
# node_7473-2497                                
echo "adding cluster edge node_7473-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_2497' 'eth_2497_7473' '30' 'None' '10.1.149.2/24' '10.1.149.1/24'
# node_7473-2914                                
echo "adding cluster edge node_7473-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_2914' 'eth_2914_7473' '30' 'None' '10.1.210.2/24' '10.1.210.1/24'
# node_7473-64050                                
echo "adding host edge node_7473-64050"                                
sleep 0.2                                
funCreateV 'eth_7473_64050' 'eth_64050_7473' '30' '37' '10.2.232.1/24' '10.2.232.2/24'
# node_7473-6939                                
echo "adding cluster edge node_7473-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_6939' 'eth_6939_7473' '30' 'None' '10.1.112.2/24' '10.1.112.1/24'
# node_7473-4775                                
echo "adding cluster edge node_7473-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_4775' 'eth_4775_7473' '30' 'None' '10.2.233.1/24' '10.2.233.2/24'
# node_7473-18403                                
echo "adding cluster edge node_7473-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_18403' 'eth_18403_7473' '30' 'None' '10.2.237.1/24' '10.2.237.2/24'
# node_3320-12552                                
echo "adding cluster edge node_3320-12552"                                
sleep 0.2                                
funCreateClusterV 'eth_3320_12552' 'eth_12552_3320' '31' 'None' '10.2.117.2/24' '10.2.117.1/24'
# node_3320-9583                                
echo "adding host edge node_3320-9583"                                
sleep 0.2                                
funCreateV 'eth_3320_9583' 'eth_9583_3320' '31' '35' '10.3.97.2/24' '10.3.97.1/24'
# node_3320-16509                                
echo "adding cluster edge node_3320-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_3320_16509' 'eth_16509_3320' '31' 'None' '10.3.102.1/24' '10.3.102.2/24'
# node_3320-4809                                
echo "adding cluster edge node_3320-4809"                                
sleep 0.2                                
funCreateClusterV 'eth_3320_4809' 'eth_4809_3320' '31' 'None' '10.3.103.1/24' '10.3.103.2/24'
# node_3320-3303                                
echo "adding cluster edge node_3320-3303"                                
sleep 0.2                                
funCreateClusterV 'eth_3320_3303' 'eth_3303_3320' '31' 'None' '10.1.56.2/24' '10.1.56.1/24'
# node_3320-5511                                
echo "adding cluster edge node_3320-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_3320_5511' 'eth_5511_3320' '31' 'None' '10.3.20.2/24' '10.3.20.1/24'
# node_3561-209                                
echo "adding cluster edge node_3561-209"                                
sleep 0.2                                
funCreateClusterV 'eth_3561_209' 'eth_209_3561' '32' 'None' '10.1.183.1/24' '10.1.183.2/24'
# node_7545-6939                                
echo "adding cluster edge node_7545-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_7545_6939' 'eth_6939_7545' '33' 'None' '10.1.76.2/24' '10.1.76.1/24'
# node_7545-1299                                
echo "adding cluster edge node_7545-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_7545_1299' 'eth_1299_7545' '33' 'None' '10.0.236.2/24' '10.0.236.1/24'
# node_7545-174                                
echo "adding cluster edge node_7545-174"                                
sleep 0.2                                
funCreateClusterV 'eth_7545_174' 'eth_174_7545' '33' 'None' '10.2.54.1/24' '10.2.54.2/24'
# node_7545-6453                                
echo "adding cluster edge node_7545-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_7545_6453' 'eth_6453_7545' '33' 'None' '10.2.55.1/24' '10.2.55.2/24'
# node_15412-5413                                
echo "adding cluster edge node_15412-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_5413' 'eth_5413_15412' '34' 'None' '10.1.185.2/24' '10.1.185.1/24'
# node_15412-3741                                
echo "adding cluster edge node_15412-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_3741' 'eth_3741_15412' '34' 'None' '10.0.161.2/24' '10.0.161.1/24'
# node_15412-1299                                
echo "adding cluster edge node_15412-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_1299' 'eth_1299_15412' '34' 'None' '10.0.239.2/24' '10.0.239.1/24'
# node_15412-6939                                
echo "adding cluster edge node_15412-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_6939' 'eth_6939_15412' '34' 'None' '10.1.84.2/24' '10.1.84.1/24'
# node_15412-4775                                
echo "adding cluster edge node_15412-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_4775' 'eth_4775_15412' '34' 'None' '10.2.178.1/24' '10.2.178.2/24'
# node_15412-174                                
echo "adding cluster edge node_15412-174"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_174' 'eth_174_15412' '34' 'None' '10.2.82.2/24' '10.2.82.1/24'
# node_15412-2914                                
echo "adding cluster edge node_15412-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_2914' 'eth_2914_15412' '34' 'None' '10.1.242.2/24' '10.1.242.1/24'
# node_15412-2152                                
echo "adding cluster edge node_15412-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_2152' 'eth_2152_15412' '34' 'None' '10.1.72.2/24' '10.1.72.1/24'
# node_9583-37100                                
echo "adding cluster edge node_9583-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_37100' 'eth_37100_9583' '35' 'None' '10.2.39.2/24' '10.2.39.1/24'
# node_9583-1299                                
echo "adding cluster edge node_9583-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_1299' 'eth_1299_9583' '35' 'None' '10.0.247.2/24' '10.0.247.1/24'
# node_9583-6453                                
echo "adding cluster edge node_9583-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_6453' 'eth_6453_9583' '35' 'None' '10.2.90.2/24' '10.2.90.1/24'
# node_9583-2914                                
echo "adding cluster edge node_9583-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_2914' 'eth_2914_9583' '35' 'None' '10.1.204.2/24' '10.1.204.1/24'
# node_9583-6939                                
echo "adding cluster edge node_9583-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_6939' 'eth_6939_9583' '35' 'None' '10.1.91.2/24' '10.1.91.1/24'
# node_9583-3491                                
echo "adding cluster edge node_9583-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_3491' 'eth_3491_9583' '35' 'None' '10.3.45.2/24' '10.3.45.1/24'
# node_9583-174                                
echo "adding cluster edge node_9583-174"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_174' 'eth_174_9583' '35' 'None' '10.2.59.2/24' '10.2.59.1/24'
# node_24785-1299                                
echo "adding cluster edge node_24785-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_24785_1299' 'eth_1299_24785' '36' 'None' '10.1.8.2/24' '10.1.8.1/24'
# node_24785-6830                                
echo "adding host edge node_24785-6830"                                
sleep 0.2                                
funCreateV 'eth_24785_6830' 'eth_6830_24785' '36' '42' '10.2.208.2/24' '10.2.208.1/24'
# node_24785-1273                                
echo "adding cluster edge node_24785-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_24785_1273' 'eth_1273_24785' '36' 'None' '10.3.85.2/24' '10.3.85.1/24'
# node_64050-2914                                
echo "adding cluster edge node_64050-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_2914' 'eth_2914_64050' '37' 'None' '10.1.226.2/24' '10.1.226.1/24'
# node_64050-9002                                
echo "adding cluster edge node_64050-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_9002' 'eth_9002_64050' '37' 'None' '10.3.34.2/24' '10.3.34.1/24'
# node_64050-6939                                
echo "adding cluster edge node_64050-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_6939' 'eth_6939_64050' '37' 'None' '10.1.110.2/24' '10.1.110.1/24'
# node_64050-3491                                
echo "adding cluster edge node_64050-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_3491' 'eth_3491_64050' '37' 'None' '10.3.49.2/24' '10.3.49.1/24'
# node_64050-4766                                
echo "adding cluster edge node_64050-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_4766' 'eth_4766_64050' '37' 'None' '10.2.252.2/24' '10.2.252.1/24'
# node_64050-3786                                
echo "adding cluster edge node_64050-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_3786' 'eth_3786_64050' '37' 'None' '10.3.136.2/24' '10.3.136.1/24'
# node_64050-20485                                
echo "adding host edge node_64050-20485"                                
sleep 0.2                                
funCreateV 'eth_64050_20485' 'eth_20485_64050' '37' '45' '10.3.31.2/24' '10.3.31.1/24'
# node_64050-1299                                
echo "adding cluster edge node_64050-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_1299' 'eth_1299_64050' '37' 'None' '10.1.10.2/24' '10.1.10.1/24'
# node_64050-293                                
echo "adding cluster edge node_64050-293"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_293' 'eth_293_64050' '37' 'None' '10.1.178.2/24' '10.1.178.1/24'
# node_10089-6939                                
echo "adding cluster edge node_10089-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_10089_6939' 'eth_6939_10089' '38' 'None' '10.1.120.2/24' '10.1.120.1/24'
# node_10089-1299                                
echo "adding cluster edge node_10089-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_10089_1299' 'eth_1299_10089' '38' 'None' '10.1.16.2/24' '10.1.16.1/24'
# node_10089-2914                                
echo "adding cluster edge node_10089-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_10089_2914' 'eth_2914_10089' '38' 'None' '10.1.231.2/24' '10.1.231.1/24'
# node_15932-2914                                
echo "adding cluster edge node_15932-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_15932_2914' 'eth_2914_15932' '39' 'None' '10.1.232.2/24' '10.1.232.1/24'
# node_15932-1299                                
echo "adding cluster edge node_15932-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_15932_1299' 'eth_1299_15932' '39' 'None' '10.1.17.2/24' '10.1.17.1/24'
# node_4538-1299                                
echo "adding cluster edge node_4538-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_1299' 'eth_1299_4538' '40' 'None' '10.1.18.2/24' '10.1.18.1/24'
# node_4538-6939                                
echo "adding cluster edge node_4538-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_6939' 'eth_6939_4538' '40' 'None' '10.1.121.2/24' '10.1.121.1/24'
# node_4538-2914                                
echo "adding cluster edge node_4538-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_2914' 'eth_2914_4538' '40' 'None' '10.1.233.2/24' '10.1.233.1/24'
# node_4538-6453                                
echo "adding cluster edge node_4538-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_6453' 'eth_6453_4538' '40' 'None' '10.2.106.2/24' '10.2.106.1/24'
# node_4538-4837                                
echo "adding cluster edge node_4538-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_4837' 'eth_4837_4538' '40' 'None' '10.3.16.2/24' '10.3.16.1/24'
# node_4538-3491                                
echo "adding cluster edge node_4538-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_3491' 'eth_3491_4538' '40' 'None' '10.3.52.2/24' '10.3.52.1/24'
# node_4826-6939                                
echo "adding cluster edge node_4826-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4826_6939' 'eth_6939_4826' '41' 'None' '10.1.129.2/24' '10.1.129.1/24'
# node_4826-3257                                
echo "adding cluster edge node_4826-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_4826_3257' 'eth_3257_4826' '41' 'None' '10.0.151.2/24' '10.0.151.1/24'
# node_4826-1299                                
echo "adding cluster edge node_4826-1299"                                
sleep 0.2                                
funCreateClusterV 'eth_4826_1299' 'eth_1299_4826' '41' 'None' '10.1.24.2/24' '10.1.24.1/24'
# node_4826-3491                                
echo "adding cluster edge node_4826-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_4826_3491' 'eth_3491_4826' '41' 'None' '10.3.57.2/24' '10.3.57.1/24'
# node_6830-57866                                
echo "adding cluster edge node_6830-57866"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_57866' 'eth_57866_6830' '42' 'None' '10.0.222.2/24' '10.0.222.1/24'
# node_6830-2497                                
echo "adding cluster edge node_6830-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_2497' 'eth_2497_6830' '42' 'None' '10.1.143.2/24' '10.1.143.1/24'
# node_6830-4837                                
echo "adding cluster edge node_6830-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_4837' 'eth_4837_6830' '42' 'None' '10.2.203.1/24' '10.2.203.2/24'
# node_6830-174                                
echo "adding cluster edge node_6830-174"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_174' 'eth_174_6830' '42' 'None' '10.2.60.2/24' '10.2.60.1/24'
# node_6830-3491                                
echo "adding cluster edge node_6830-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_3491' 'eth_3491_6830' '42' 'None' '10.2.204.1/24' '10.2.204.2/24'
# node_6830-3786                                
echo "adding cluster edge node_6830-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_3786' 'eth_3786_6830' '42' 'None' '10.2.205.1/24' '10.2.205.2/24'
# node_6830-4134                                
echo "adding cluster edge node_6830-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_4134' 'eth_4134_6830' '42' 'None' '10.2.206.1/24' '10.2.206.2/24'
# node_6830-4766                                
echo "adding cluster edge node_6830-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_4766' 'eth_4766_6830' '42' 'None' '10.2.207.1/24' '10.2.207.2/24'
# node_6830-1273                                
echo "adding cluster edge node_6830-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_1273' 'eth_1273_6830' '42' 'None' '10.2.209.1/24' '10.2.209.2/24'
# node_6830-701                                
echo "adding cluster edge node_6830-701"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_701' 'eth_701_6830' '42' 'None' '10.2.210.1/24' '10.2.210.2/24'
# node_6830-3257                                
echo "adding cluster edge node_6830-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_3257' 'eth_3257_6830' '42' 'None' '10.0.147.2/24' '10.0.147.1/24'
# node_6830-4637                                
echo "adding cluster edge node_6830-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_4637' 'eth_4637_6830' '42' 'None' '10.2.144.2/24' '10.2.144.1/24'
# node_6830-5511                                
echo "adding cluster edge node_6830-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_6830_5511' 'eth_5511_6830' '42' 'None' '10.2.211.1/24' '10.2.211.2/24'
# node_20764-174                                
echo "adding cluster edge node_20764-174"                                
sleep 0.2                                
funCreateClusterV 'eth_20764_174' 'eth_174_20764' '43' 'None' '10.2.63.2/24' '10.2.63.1/24'
# node_20764-64049                                
echo "adding cluster edge node_20764-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_20764_64049' 'eth_64049_20764' '43' 'None' '10.3.116.2/24' '10.3.116.1/24'
# node_20764-4134                                
echo "adding cluster edge node_20764-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_20764_4134' 'eth_4134_20764' '43' 'None' '10.3.71.2/24' '10.3.71.1/24'
# node_20764-38040                                
echo "adding cluster edge node_20764-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_20764_38040' 'eth_38040_20764' '43' 'None' '10.2.221.2/24' '10.2.221.1/24'
# node_1237-4766                                
echo "adding cluster edge node_1237-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_1237_4766' 'eth_4766_1237' '44' 'None' '10.2.248.2/24' '10.2.248.1/24'
# node_1237-174                                
echo "adding cluster edge node_1237-174"                                
sleep 0.2                                
funCreateClusterV 'eth_1237_174' 'eth_174_1237' '44' 'None' '10.2.68.2/24' '10.2.68.1/24'
# node_20485-4837                                
echo "adding cluster edge node_20485-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_4837' 'eth_4837_20485' '45' 'None' '10.3.9.2/24' '10.3.9.1/24'
# node_20485-3491                                
echo "adding cluster edge node_20485-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_3491' 'eth_3491_20485' '45' 'None' '10.3.28.1/24' '10.3.28.2/24'
# node_20485-132203                                
echo "adding cluster edge node_20485-132203"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_132203' 'eth_132203_20485' '45' 'None' '10.3.29.1/24' '10.3.29.2/24'
# node_20485-174                                
echo "adding cluster edge node_20485-174"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_174' 'eth_174_20485' '45' 'None' '10.2.69.2/24' '10.2.69.1/24'
# node_20485-16509                                
echo "adding cluster edge node_20485-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_16509' 'eth_16509_20485' '45' 'None' '10.3.32.1/24' '10.3.32.2/24'
# node_7497-3491                                
echo "adding cluster edge node_7497-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_7497_3491' 'eth_3491_7497' '46' 'None' '10.3.46.2/24' '10.3.46.1/24'
# node_7497-4134                                
echo "adding cluster edge node_7497-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_7497_4134' 'eth_4134_7497' '46' 'None' '10.3.63.2/24' '10.3.63.1/24'
# node_7497-174                                
echo "adding cluster edge node_7497-174"                                
sleep 0.2                                
funCreateClusterV 'eth_7497_174' 'eth_174_7497' '46' 'None' '10.2.70.2/24' '10.2.70.1/24'
# node_9929-174                                
echo "adding cluster edge node_9929-174"                                
sleep 0.2                                
funCreateClusterV 'eth_9929_174' 'eth_174_9929' '47' 'None' '10.2.74.2/24' '10.2.74.1/24'
# node_9929-4837                                
echo "adding cluster edge node_9929-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_9929_4837' 'eth_4837_9929' '47' 'None' '10.3.15.2/24' '10.3.15.1/24'
# node_9929-2914                                
echo "adding cluster edge node_9929-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9929_2914' 'eth_2914_9929' '47' 'None' '10.1.225.2/24' '10.1.225.1/24'
# node_9929-701                                
echo "adding cluster edge node_9929-701"                                
sleep 0.2                                
funCreateClusterV 'eth_9929_701' 'eth_701_9929' '47' 'None' '10.3.167.2/24' '10.3.167.1/24'
# node_9929-1239                                
echo "adding cluster edge node_9929-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_9929_1239' 'eth_1239_9929' '47' 'None' '10.2.27.2/24' '10.2.27.1/24'
# node_7670-2497                                
echo "adding cluster edge node_7670-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_7670_2497' 'eth_2497_7670' '48' 'None' '10.1.142.2/24' '10.1.142.1/24'
# node_7670-2519                                
echo "adding cluster edge node_7670-2519"                                
sleep 0.2                                
funCreateClusterV 'eth_7670_2519' 'eth_2519_7670' '48' 'None' '10.2.113.2/24' '10.2.113.1/24'
# node_7670-6939                                
echo "adding cluster edge node_7670-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_7670_6939' 'eth_6939_7670' '48' 'None' '10.1.85.2/24' '10.1.85.1/24'
# node_7670-4637                                
echo "adding cluster edge node_7670-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_7670_4637' 'eth_4637_7670' '48' 'None' '10.2.136.2/24' '10.2.136.1/24'
# node_7670-2516                                
echo "adding cluster edge node_7670-2516"                                
sleep 0.2                                
funCreateClusterV 'eth_7670_2516' 'eth_2516_7670' '48' 'None' '10.2.202.1/24' '10.2.202.2/24'
# node_23352-3257                                
echo "adding cluster edge node_23352-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_23352_3257' 'eth_3257_23352' '49' 'None' '10.0.133.2/24' '10.0.133.1/24'
# node_23352-2914                                
echo "adding cluster edge node_23352-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_23352_2914' 'eth_2914_23352' '49' 'None' '10.1.213.2/24' '10.1.213.1/24'