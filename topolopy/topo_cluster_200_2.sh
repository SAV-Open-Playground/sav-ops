#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("13237" "137753" "57304" "21859" "22548" "5539" "38634" "2514" "24157" "9924" "49367" "3216" "23969" "131293" "134166" "11164" "2153" "12975" "22388" "23911" "138421" "4808" "139007" "9808" "3130" "4755" "55836" "20562" "4760" "38819" "9848" "20130" "53767" "38091" "59125" "131099" "9858" "9286" "4791" "18305" "18176" "10190" "38707" "55627" "7562" "58461" "4811" "58466" "134756" "38283" "4847" "140647" "142404" "132147" "134768" "23724" "4812" "139019" "137687" "139018" "139587" "131098" "23599" "23596" "23600" "9526" "45376" "55633" "9684" "45528" "38266" "132199" "45271" "1221" "11537" "12389" "396982" "141750" "55329" "4621" "134809" "45996" "131100" "23588" "9579" "9630" "9638" "9730" "38099" "134089" "4725" "4804" "7474" "2764" "137130" "140202" "396421" "9587" "24361" "9723" )
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
# node_13237-37100                                
echo "adding cluster edge node_13237-37100"                                
sleep 0.2                                
funCreateClusterV 'eth_13237_37100' 'eth_37100_13237' '0' 'None' '10.2.47.2/24' '10.2.47.1/24'
# node_13237-8763                                
echo "adding cluster edge node_13237-8763"                                
sleep 0.2                                
funCreateClusterV 'eth_13237_8763' 'eth_8763_13237' '0' 'None' '10.3.193.1/24' '10.3.193.2/24'
# node_13237-3257                                
echo "adding cluster edge node_13237-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_13237_3257' 'eth_3257_13237' '0' 'None' '10.0.139.2/24' '10.0.139.1/24'
# node_13237-3741                                
echo "adding cluster edge node_13237-3741"                                
sleep 0.2                                
funCreateClusterV 'eth_13237_3741' 'eth_3741_13237' '0' 'None' '10.0.171.2/24' '10.0.171.1/24'
# node_13237-5413                                
echo "adding cluster edge node_13237-5413"                                
sleep 0.2                                
funCreateClusterV 'eth_13237_5413' 'eth_5413_13237' '0' 'None' '10.1.189.2/24' '10.1.189.1/24'
# node_137753-6939                                
echo "adding cluster edge node_137753-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_137753_6939' 'eth_6939_137753' '1' 'None' '10.1.127.2/24' '10.1.127.1/24'
# node_137753-3257                                
echo "adding cluster edge node_137753-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_137753_3257' 'eth_3257_137753' '1' 'None' '10.0.146.2/24' '10.0.146.1/24'
# node_57304-8492                                
echo "adding cluster edge node_57304-8492"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_8492' 'eth_8492_57304' '2' 'None' '10.0.232.2/24' '10.0.232.1/24'
# node_57304-6453                                
echo "adding cluster edge node_57304-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_6453' 'eth_6453_57304' '2' 'None' '10.2.93.2/24' '10.2.93.1/24'
# node_57304-64049                                
echo "adding cluster edge node_57304-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_64049' 'eth_64049_57304' '2' 'None' '10.3.109.1/24' '10.3.109.2/24'
# node_57304-4766                                
echo "adding cluster edge node_57304-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_4766' 'eth_4766_57304' '2' 'None' '10.2.245.2/24' '10.2.245.1/24'
# node_57304-3786                                
echo "adding cluster edge node_57304-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_3786' 'eth_3786_57304' '2' 'None' '10.3.110.1/24' '10.3.110.2/24'
# node_57304-64050                                
echo "adding cluster edge node_57304-64050"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_64050' 'eth_64050_57304' '2' 'None' '10.3.111.1/24' '10.3.111.2/24'
# node_57304-4775                                
echo "adding cluster edge node_57304-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_4775' 'eth_4775_57304' '2' 'None' '10.3.112.1/24' '10.3.112.2/24'
# node_57304-1273                                
echo "adding cluster edge node_57304-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_1273' 'eth_1273_57304' '2' 'None' '10.3.86.2/24' '10.3.86.1/24'
# node_57304-6461                                
echo "adding cluster edge node_57304-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_6461' 'eth_6461_57304' '2' 'None' '10.2.194.2/24' '10.2.194.1/24'
# node_57304-3257                                
echo "adding cluster edge node_57304-3257"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_3257' 'eth_3257_57304' '2' 'None' '10.0.148.2/24' '10.0.148.1/24'
# node_57304-5511                                
echo "adding cluster edge node_57304-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_5511' 'eth_5511_57304' '2' 'None' '10.3.21.2/24' '10.3.21.1/24'
# node_57304-9505                                
echo "adding cluster edge node_57304-9505"                                
sleep 0.2                                
funCreateClusterV 'eth_57304_9505' 'eth_9505_57304' '2' 'None' '10.3.113.1/24' '10.3.113.2/24'
# node_21859-6453                                
echo "adding cluster edge node_21859-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_6453' 'eth_6453_21859' '3' 'None' '10.2.87.2/24' '10.2.87.1/24'
# node_21859-2914                                
echo "adding cluster edge node_21859-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_2914' 'eth_2914_21859' '3' 'None' '10.1.201.2/24' '10.1.201.1/24'
# node_21859-3491                                
echo "adding cluster edge node_21859-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_3491' 'eth_3491_21859' '3' 'None' '10.3.40.1/24' '10.3.40.2/24'
# node_21859-18106                                
echo "adding cluster edge node_21859-18106"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_18106' 'eth_18106_21859' '3' 'None' '10.0.180.2/24' '10.0.180.1/24'
# node_21859-20485                                
echo "adding cluster edge node_21859-20485"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_20485' 'eth_20485_21859' '3' 'None' '10.3.26.2/24' '10.3.26.1/24'
# node_21859-6939                                
echo "adding cluster edge node_21859-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_6939' 'eth_6939_21859' '3' 'None' '10.1.89.2/24' '10.1.89.1/24'
# node_21859-23673                                
echo "adding cluster edge node_21859-23673"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_23673' 'eth_23673_21859' '3' 'None' '10.1.245.2/24' '10.1.245.1/24'
# node_21859-55410                                
echo "adding cluster edge node_21859-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_21859_55410' 'eth_55410_21859' '3' 'None' '10.3.41.1/24' '10.3.41.2/24'
# node_22548-2914                                
echo "adding cluster edge node_22548-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_22548_2914' 'eth_2914_22548' '4' 'None' '10.1.218.2/24' '10.1.218.1/24'
# node_22548-23596                                
echo "adding host edge node_22548-23596"                                
sleep 0.2                                
funCreateV 'eth_22548_23596' 'eth_23596_22548' '4' '63' '10.3.183.2/24' '10.3.183.1/24'
# node_22548-6939                                
echo "adding cluster edge node_22548-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_22548_6939' 'eth_6939_22548' '4' 'None' '10.1.103.2/24' '10.1.103.1/24'
# node_22548-16735                                
echo "adding cluster edge node_22548-16735"                                
sleep 0.2                                
funCreateClusterV 'eth_22548_16735' 'eth_16735_22548' '4' 'None' '10.3.190.1/24' '10.3.190.2/24'
# node_5539-33891                                
echo "adding cluster edge node_5539-33891"                                
sleep 0.2                                
funCreateClusterV 'eth_5539_33891' 'eth_33891_5539' '5' 'None' '10.3.197.2/24' '10.3.197.1/24'
# node_5539-8763                                
echo "adding cluster edge node_5539-8763"                                
sleep 0.2                                
funCreateClusterV 'eth_5539_8763' 'eth_8763_5539' '5' 'None' '10.3.195.2/24' '10.3.195.1/24'
# node_5539-2914                                
echo "adding cluster edge node_5539-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_5539_2914' 'eth_2914_5539' '5' 'None' '10.1.219.2/24' '10.1.219.1/24'
# node_38634-2516                                
echo "adding cluster edge node_38634-2516"                                
sleep 0.2                                
funCreateClusterV 'eth_38634_2516' 'eth_2516_38634' '6' 'None' '10.2.212.2/24' '10.2.212.1/24'
# node_38634-59125                                
echo "adding host edge node_38634-59125"                                
sleep 0.2                                
funCreateV 'eth_38634_59125' 'eth_59125_38634' '6' '34' '10.3.198.2/24' '10.3.198.1/24'
# node_38634-2914                                
echo "adding cluster edge node_38634-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_38634_2914' 'eth_2914_38634' '6' 'None' '10.1.222.2/24' '10.1.222.1/24'
# node_2514-6939                                
echo "adding cluster edge node_2514-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_2514_6939' 'eth_6939_2514' '7' 'None' '10.1.113.2/24' '10.1.113.1/24'
# node_2514-2497                                
echo "adding cluster edge node_2514-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_2514_2497' 'eth_2497_2514' '7' 'None' '10.1.160.2/24' '10.1.160.1/24'
# node_2514-2914                                
echo "adding cluster edge node_2514-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_2514_2914' 'eth_2914_2514' '7' 'None' '10.1.227.2/24' '10.1.227.1/24'
# node_2514-6453                                
echo "adding cluster edge node_2514-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_2514_6453' 'eth_6453_2514' '7' 'None' '10.2.103.2/24' '10.2.103.1/24'
# node_2514-9605                                
echo "adding cluster edge node_2514-9605"                                
sleep 0.2                                
funCreateClusterV 'eth_2514_9605' 'eth_9605_2514' '7' 'None' '10.3.205.1/24' '10.3.205.2/24'
# node_24157-2914                                
echo "adding cluster edge node_24157-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_24157_2914' 'eth_2914_24157' '8' 'None' '10.1.240.2/24' '10.1.240.1/24'
# node_24157-9505                                
echo "adding cluster edge node_24157-9505"                                
sleep 0.2                                
funCreateClusterV 'eth_24157_9505' 'eth_9505_24157' '8' 'None' '10.3.239.1/24' '10.3.239.2/24'
# node_24157-6939                                
echo "adding cluster edge node_24157-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_24157_6939' 'eth_6939_24157' '8' 'None' '10.1.134.2/24' '10.1.134.1/24'
# node_24157-9924                                
echo "adding host edge node_24157-9924"                                
sleep 0.2                                
funCreateV 'eth_24157_9924' 'eth_9924_24157' '8' '9' '10.3.240.1/24' '10.3.240.2/24'
# node_24157-15412                                
echo "adding cluster edge node_24157-15412"                                
sleep 0.2                                
funCreateClusterV 'eth_24157_15412' 'eth_15412_24157' '8' 'None' '10.2.180.2/24' '10.2.180.1/24'
# node_24157-58453                                
echo "adding cluster edge node_24157-58453"                                
sleep 0.2                                
funCreateClusterV 'eth_24157_58453' 'eth_58453_24157' '8' 'None' '10.2.227.2/24' '10.2.227.1/24'
# node_9924-3491                                
echo "adding cluster edge node_9924-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_9924_3491' 'eth_3491_9924' '9' 'None' '10.3.58.2/24' '10.3.58.1/24'
# node_9924-2914                                
echo "adding cluster edge node_9924-2914"                                
sleep 0.2                                
funCreateClusterV 'eth_9924_2914' 'eth_2914_9924' '9' 'None' '10.1.241.2/24' '10.1.241.1/24'
# node_49367-20912                                
echo "adding cluster edge node_49367-20912"                                
sleep 0.2                                
funCreateClusterV 'eth_49367_20912' 'eth_20912_49367' '10' 'None' '10.0.123.2/24' '10.0.123.1/24'
# node_49367-6762                                
echo "adding cluster edge node_49367-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_49367_6762' 'eth_6762_49367' '10' 'None' '10.2.169.2/24' '10.2.169.1/24'
# node_3216-8492                                
echo "adding cluster edge node_3216-8492"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_8492' 'eth_8492_3216' '11' 'None' '10.0.229.2/24' '10.0.229.1/24'
# node_3216-9304                                
echo "adding cluster edge node_3216-9304"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_9304' 'eth_9304_3216' '11' 'None' '10.2.165.2/24' '10.2.165.1/24'
# node_3216-1273                                
echo "adding cluster edge node_3216-1273"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_1273' 'eth_1273_3216' '11' 'None' '10.2.196.1/24' '10.2.196.2/24'
# node_3216-64050                                
echo "adding cluster edge node_3216-64050"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_64050' 'eth_64050_3216' '11' 'None' '10.2.197.1/24' '10.2.197.2/24'
# node_3216-6762                                
echo "adding cluster edge node_3216-6762"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_6762' 'eth_6762_3216' '11' 'None' '10.2.172.2/24' '10.2.172.1/24'
# node_3216-3462                                
echo "adding cluster edge node_3216-3462"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_3462' 'eth_3462_3216' '11' 'None' '10.2.198.1/24' '10.2.198.2/24'
# node_3216-9605                                
echo "adding cluster edge node_3216-9605"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_9605' 'eth_9605_3216' '11' 'None' '10.2.199.1/24' '10.2.199.2/24'
# node_3216-2497                                
echo "adding cluster edge node_3216-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_2497' 'eth_2497_3216' '11' 'None' '10.1.166.2/24' '10.1.166.1/24'
# node_3216-9318                                
echo "adding cluster edge node_3216-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_3216_9318' 'eth_9318_3216' '11' 'None' '10.2.200.1/24' '10.2.200.2/24'
# node_23969-38040                                
echo "adding cluster edge node_23969-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_23969_38040' 'eth_38040_23969' '12' 'None' '10.2.213.1/24' '10.2.213.2/24'
# node_23969-4651                                
echo "adding cluster edge node_23969-4651"                                
sleep 0.2                                
funCreateClusterV 'eth_23969_4651' 'eth_4651_23969' '12' 'None' '10.2.214.1/24' '10.2.214.2/24'
# node_131293-4651                                
echo "adding cluster edge node_131293-4651"                                
sleep 0.2                                
funCreateClusterV 'eth_131293_4651' 'eth_4651_131293' '13' 'None' '10.2.242.2/24' '10.2.242.1/24'
# node_131293-38040                                
echo "adding cluster edge node_131293-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_131293_38040' 'eth_38040_131293' '13' 'None' '10.2.222.2/24' '10.2.222.1/24'
# node_134166-38040                                
echo "adding cluster edge node_134166-38040"                                
sleep 0.2                                
funCreateClusterV 'eth_134166_38040' 'eth_38040_134166' '14' 'None' '10.2.223.2/24' '10.2.223.1/24'
# node_11164-2152                                
echo "adding cluster edge node_11164-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_2152' 'eth_2152_11164' '15' 'None' '10.1.59.2/24' '10.1.59.1/24'
# node_11164-2497                                
echo "adding cluster edge node_11164-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_2497' 'eth_2497_11164' '15' 'None' '10.1.138.2/24' '10.1.138.1/24'
# node_11164-3491                                
echo "adding cluster edge node_11164-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_3491' 'eth_3491_11164' '15' 'None' '10.2.158.1/24' '10.2.158.2/24'
# node_11164-4788                                
echo "adding cluster edge node_11164-4788"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_4788' 'eth_4788_11164' '15' 'None' '10.2.159.1/24' '10.2.159.2/24'
# node_11164-4134                                
echo "adding cluster edge node_11164-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_4134' 'eth_4134_11164' '15' 'None' '10.2.160.1/24' '10.2.160.2/24'
# node_11164-4637                                
echo "adding cluster edge node_11164-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_11164_4637' 'eth_4637_11164' '15' 'None' '10.2.137.2/24' '10.2.137.1/24'
# node_2153-2152                                
echo "adding cluster edge node_2153-2152"                                
sleep 0.2                                
funCreateClusterV 'eth_2153_2152' 'eth_2152_2153' '16' 'None' '10.1.63.2/24' '10.1.63.1/24'
# node_2153-11537                                
echo "adding host edge node_2153-11537"                                
sleep 0.2                                
funCreateV 'eth_2153_11537' 'eth_11537_2153' '16' '74' '10.3.127.1/24' '10.3.127.2/24'
# node_2153-22388                                
echo "adding host edge node_2153-22388"                                
sleep 0.2                                
funCreateV 'eth_2153_22388' 'eth_22388_2153' '16' '18' '10.3.128.1/24' '10.3.128.2/24'
# node_12975-5511                                
echo "adding cluster edge node_12975-5511"                                
sleep 0.2                                
funCreateClusterV 'eth_12975_5511' 'eth_5511_12975' '17' 'None' '10.3.19.2/24' '10.3.19.1/24'
# node_12975-6663                                
echo "adding cluster edge node_12975-6663"                                
sleep 0.2                                
funCreateClusterV 'eth_12975_6663' 'eth_6663_12975' '17' 'None' '10.3.232.1/24' '10.3.232.2/24'
# node_22388-293                                
echo "adding cluster edge node_22388-293"                                
sleep 0.2                                
funCreateClusterV 'eth_22388_293' 'eth_293_22388' '18' 'None' '10.1.176.2/24' '10.1.176.1/24'
# node_22388-23911                                
echo "adding host edge node_22388-23911"                                
sleep 0.2                                
funCreateV 'eth_22388_23911' 'eth_23911_22388' '18' '19' '10.3.186.1/24' '10.3.186.2/24'
# node_23911-293                                
echo "adding cluster edge node_23911-293"                                
sleep 0.2                                
funCreateClusterV 'eth_23911_293' 'eth_293_23911' '19' 'None' '10.1.179.2/24' '10.1.179.1/24'
# node_23911-4538                                
echo "adding cluster edge node_23911-4538"                                
sleep 0.2                                
funCreateClusterV 'eth_23911_4538' 'eth_4538_23911' '19' 'None' '10.3.217.2/24' '10.3.217.1/24'
# node_23911-11537                                
echo "adding host edge node_23911-11537"                                
sleep 0.2                                
funCreateV 'eth_23911_11537' 'eth_11537_23911' '19' '74' '10.3.131.2/24' '10.3.131.1/24'
# node_138421-4837                                
echo "adding cluster edge node_138421-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_138421_4837' 'eth_4837_138421' '20' 'None' '10.3.6.1/24' '10.3.6.2/24'
# node_4808-4837                                
echo "adding cluster edge node_4808-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_4808_4837' 'eth_4837_4808' '21' 'None' '10.3.10.2/24' '10.3.10.1/24'
# node_139007-4837                                
echo "adding cluster edge node_139007-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_139007_4837' 'eth_4837_139007' '22' 'None' '10.3.13.2/24' '10.3.13.1/24'
# node_9808-58453                                
echo "adding cluster edge node_9808-58453"                                
sleep 0.2                                
funCreateClusterV 'eth_9808_58453' 'eth_58453_9808' '23' 'None' '10.2.226.2/24' '10.2.226.1/24'
# node_9808-4134                                
echo "adding cluster edge node_9808-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_9808_4134' 'eth_4134_9808' '23' 'None' '10.3.77.2/24' '10.3.77.1/24'
# node_9808-4837                                
echo "adding cluster edge node_9808-4837"                                
sleep 0.2                                
funCreateClusterV 'eth_9808_4837' 'eth_4837_9808' '23' 'None' '10.3.17.2/24' '10.3.17.1/24'
# node_3130-1239                                
echo "adding cluster edge node_3130-1239"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_1239' 'eth_1239_3130' '24' 'None' '10.2.9.1/24' '10.2.9.2/24'
# node_3130-6939                                
echo "adding cluster edge node_3130-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_6939' 'eth_6939_3130' '24' 'None' '10.1.80.2/24' '10.1.80.1/24'
# node_3130-2497                                
echo "adding cluster edge node_3130-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_2497' 'eth_2497_3130' '24' 'None' '10.1.139.2/24' '10.1.139.1/24'
# node_3130-9318                                
echo "adding cluster edge node_3130-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_9318' 'eth_9318_3130' '24' 'None' '10.2.10.1/24' '10.2.10.2/24'
# node_3130-9002                                
echo "adding cluster edge node_3130-9002"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_9002' 'eth_9002_3130' '24' 'None' '10.2.11.1/24' '10.2.11.2/24'
# node_3130-15169                                
echo "adding cluster edge node_3130-15169"                                
sleep 0.2                                
funCreateClusterV 'eth_3130_15169' 'eth_15169_3130' '24' 'None' '10.2.13.1/24' '10.2.13.2/24'
# node_4755-6453                                
echo "adding cluster edge node_4755-6453"                                
sleep 0.2                                
funCreateClusterV 'eth_4755_6453' 'eth_6453_4755' '25' 'None' '10.2.91.2/24' '10.2.91.1/24'
# node_4755-9583                                
echo "adding cluster edge node_4755-9583"                                
sleep 0.2                                
funCreateClusterV 'eth_4755_9583' 'eth_9583_4755' '25' 'None' '10.3.98.2/24' '10.3.98.1/24'
# node_4755-396421                                
echo "adding host edge node_4755-396421"                                
sleep 0.2                                
funCreateV 'eth_4755_396421' 'eth_396421_4755' '25' '96' '10.3.105.1/24' '10.3.105.2/24'
# node_4755-45528                                
echo "adding host edge node_4755-45528"                                
sleep 0.2                                
funCreateV 'eth_4755_45528' 'eth_45528_4755' '25' '69' '10.3.106.1/24' '10.3.106.2/24'
# node_4755-55410                                
echo "adding cluster edge node_4755-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_4755_55410' 'eth_55410_4755' '25' 'None' '10.3.107.1/24' '10.3.107.2/24'
# node_55836-64049                                
echo "adding cluster edge node_55836-64049"                                
sleep 0.2                                
funCreateClusterV 'eth_55836_64049' 'eth_64049_55836' '26' 'None' '10.3.115.2/24' '10.3.115.1/24'
# node_20562-6461                                
echo "adding cluster edge node_20562-6461"                                
sleep 0.2                                
funCreateClusterV 'eth_20562_6461' 'eth_6461_20562' '27' 'None' '10.2.189.2/24' '10.2.189.1/24'
# node_20562-8763                                
echo "adding cluster edge node_20562-8763"                                
sleep 0.2                                
funCreateClusterV 'eth_20562_8763' 'eth_8763_20562' '27' 'None' '10.3.196.2/24' '10.3.196.1/24'
# node_4760-6939                                
echo "adding cluster edge node_4760-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_4760_6939' 'eth_6939_4760' '28' 'None' '10.1.116.2/24' '10.1.116.1/24'
# node_4760-3491                                
echo "adding cluster edge node_4760-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_4760_3491' 'eth_3491_4760' '28' 'None' '10.3.50.2/24' '10.3.50.1/24'
# node_4760-38819                                
echo "adding host edge node_4760-38819"                                
sleep 0.2                                
funCreateV 'eth_4760_38819' 'eth_38819_4760' '28' '29' '10.3.207.1/24' '10.3.207.2/24'
# node_38819-3491                                
echo "adding cluster edge node_38819-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_38819_3491' 'eth_3491_38819' '29' 'None' '10.3.54.2/24' '10.3.54.1/24'
# node_9848-3491                                
echo "adding cluster edge node_9848-3491"                                
sleep 0.2                                
funCreateClusterV 'eth_9848_3491' 'eth_3491_9848' '30' 'None' '10.3.60.2/24' '10.3.60.1/24'
# node_9848-23588                                
echo "adding host edge node_9848-23588"                                
sleep 0.2                                
funCreateV 'eth_9848_23588' 'eth_23588_9848' '30' '83' '10.3.242.2/24' '10.3.242.1/24'
# node_9848-23764                                
echo "adding cluster edge node_9848-23764"                                
sleep 0.2                                
funCreateClusterV 'eth_9848_23764' 'eth_23764_9848' '30' 'None' '10.3.96.2/24' '10.3.96.1/24'
# node_9848-7562                                
echo "adding host edge node_9848-7562"                                
sleep 0.2                                
funCreateV 'eth_9848_7562' 'eth_7562_9848' '30' '44' '10.3.243.1/24' '10.3.243.2/24'
# node_9848-58453                                
echo "adding cluster edge node_9848-58453"                                
sleep 0.2                                
funCreateClusterV 'eth_9848_58453' 'eth_58453_9848' '30' 'None' '10.2.229.2/24' '10.2.229.1/24'
# node_20130-6939                                
echo "adding cluster edge node_20130-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_20130_6939' 'eth_6939_20130' '31' 'None' '10.1.73.1/24' '10.1.73.2/24'
# node_20130-23352                                
echo "adding cluster edge node_20130-23352"                                
sleep 0.2                                
funCreateClusterV 'eth_20130_23352' 'eth_23352_20130' '31' 'None' '10.1.74.1/24' '10.1.74.2/24'
# node_53767-6939                                
echo "adding cluster edge node_53767-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_53767_6939' 'eth_6939_53767' '32' 'None' '10.1.77.2/24' '10.1.77.1/24'
# node_38091-3786                                
echo "adding cluster edge node_38091-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_38091_3786' 'eth_3786_38091' '33' 'None' '10.3.133.2/24' '10.3.133.1/24'
# node_38091-6939                                
echo "adding cluster edge node_38091-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_38091_6939' 'eth_6939_38091' '33' 'None' '10.1.97.2/24' '10.1.97.1/24'
# node_38091-9957                                
echo "adding cluster edge node_38091-9957"                                
sleep 0.2                                
funCreateClusterV 'eth_38091_9957' 'eth_9957_38091' '33' 'None' '10.3.149.1/24' '10.3.149.2/24'
# node_38091-9318                                
echo "adding cluster edge node_38091-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_38091_9318' 'eth_9318_38091' '33' 'None' '10.3.152.1/24' '10.3.152.2/24'
# node_59125-2497                                
echo "adding cluster edge node_59125-2497"                                
sleep 0.2                                
funCreateClusterV 'eth_59125_2497' 'eth_2497_59125' '34' 'None' '10.1.157.2/24' '10.1.157.1/24'
# node_59125-17676                                
echo "adding cluster edge node_59125-17676"                                
sleep 0.2                                
funCreateClusterV 'eth_59125_17676' 'eth_17676_59125' '34' 'None' '10.3.89.2/24' '10.3.89.1/24'
# node_59125-6939                                
echo "adding cluster edge node_59125-6939"                                
sleep 0.2                                
funCreateClusterV 'eth_59125_6939' 'eth_6939_59125' '34' 'None' '10.1.105.2/24' '10.1.105.1/24'
# node_59125-20485                                
echo "adding cluster edge node_59125-20485"                                
sleep 0.2                                
funCreateClusterV 'eth_59125_20485' 'eth_20485_59125' '34' 'None' '10.3.30.2/24' '10.3.30.1/24'
# node_59125-9607                                
echo "adding cluster edge node_59125-9607"                                
sleep 0.2                                
funCreateClusterV 'eth_59125_9607' 'eth_9607_59125' '34' 'None' '10.3.199.1/24' '10.3.199.2/24'
# node_131099-3786                                
echo "adding cluster edge node_131099-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_131099_3786' 'eth_3786_131099' '35' 'None' '10.3.134.2/24' '10.3.134.1/24'
# node_9858-9318                                
echo "adding cluster edge node_9858-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9858_9318' 'eth_9318_9858' '36' 'None' '10.3.157.2/24' '10.3.157.1/24'
# node_9858-23600                                
echo "adding host edge node_9858-23600"                                
sleep 0.2                                
funCreateV 'eth_9858_23600' 'eth_23600_9858' '36' '64' '10.3.191.2/24' '10.3.191.1/24'
# node_9858-4766                                
echo "adding cluster edge node_9858-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9858_4766' 'eth_4766_9858' '36' 'None' '10.2.250.2/24' '10.2.250.1/24'
# node_9858-3786                                
echo "adding cluster edge node_9858-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_9858_3786' 'eth_3786_9858' '36' 'None' '10.3.135.2/24' '10.3.135.1/24'
# node_9286-9957                                
echo "adding cluster edge node_9286-9957"                                
sleep 0.2                                
funCreateClusterV 'eth_9286_9957' 'eth_9957_9286' '37' 'None' '10.3.169.2/24' '10.3.169.1/24'
# node_9286-23599                                
echo "adding host edge node_9286-23599"                                
sleep 0.2                                
funCreateV 'eth_9286_23599' 'eth_23599_9286' '37' '62' '10.3.180.2/24' '10.3.180.1/24'
# node_9286-23588                                
echo "adding host edge node_9286-23588"                                
sleep 0.2                                
funCreateV 'eth_9286_23588' 'eth_23588_9286' '37' '83' '10.3.181.1/24' '10.3.181.2/24'
# node_9286-4766                                
echo "adding cluster edge node_9286-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9286_4766' 'eth_4766_9286' '37' 'None' '10.2.255.2/24' '10.2.255.1/24'
# node_9286-3786                                
echo "adding cluster edge node_9286-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_9286_3786' 'eth_3786_9286' '37' 'None' '10.3.138.2/24' '10.3.138.1/24'
# node_9286-9318                                
echo "adding cluster edge node_9286-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9286_9318' 'eth_9318_9286' '37' 'None' '10.3.160.2/24' '10.3.160.1/24'
# node_4791-3786                                
echo "adding cluster edge node_4791-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_4791_3786' 'eth_3786_4791' '38' 'None' '10.3.139.2/24' '10.3.139.1/24'
# node_18305-3786                                
echo "adding cluster edge node_18305-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_18305_3786' 'eth_3786_18305' '39' 'None' '10.3.140.2/24' '10.3.140.1/24'
# node_18305-9318                                
echo "adding cluster edge node_18305-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_18305_9318' 'eth_9318_18305' '39' 'None' '10.3.163.2/24' '10.3.163.1/24'
# node_18176-3786                                
echo "adding cluster edge node_18176-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_18176_3786' 'eth_3786_18176' '40' 'None' '10.3.141.2/24' '10.3.141.1/24'
# node_10190-3786                                
echo "adding cluster edge node_10190-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_10190_3786' 'eth_3786_10190' '41' 'None' '10.3.142.2/24' '10.3.142.1/24'
# node_38707-3786                                
echo "adding cluster edge node_38707-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_38707_3786' 'eth_3786_38707' '42' 'None' '10.3.143.2/24' '10.3.143.1/24'
# node_55627-3786                                
echo "adding cluster edge node_55627-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_55627_3786' 'eth_3786_55627' '43' 'None' '10.3.144.2/24' '10.3.144.1/24'
# node_7562-3786                                
echo "adding cluster edge node_7562-3786"                                
sleep 0.2                                
funCreateClusterV 'eth_7562_3786' 'eth_3786_7562' '44' 'None' '10.3.145.2/24' '10.3.145.1/24'
# node_7562-4766                                
echo "adding cluster edge node_7562-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_7562_4766' 'eth_4766_7562' '44' 'None' '10.3.5.2/24' '10.3.5.1/24'
# node_58461-4134                                
echo "adding cluster edge node_58461-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_58461_4134' 'eth_4134_58461' '45' 'None' '10.3.62.2/24' '10.3.62.1/24'
# node_4811-4134                                
echo "adding cluster edge node_4811-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_4811_4134' 'eth_4134_4811' '46' 'None' '10.3.64.2/24' '10.3.64.1/24'
# node_4811-4812                                
echo "adding host edge node_4811-4812"                                
sleep 0.2                                
funCreateV 'eth_4811_4812' 'eth_4812_4811' '46' '56' '10.3.174.1/24' '10.3.174.2/24'
# node_58466-4134                                
echo "adding cluster edge node_58466-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_58466_4134' 'eth_4134_58466' '47' 'None' '10.3.65.2/24' '10.3.65.1/24'
# node_134756-4134                                
echo "adding cluster edge node_134756-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_134756_4134' 'eth_4134_134756' '48' 'None' '10.3.66.2/24' '10.3.66.1/24'
# node_38283-4134                                
echo "adding cluster edge node_38283-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_38283_4134' 'eth_4134_38283' '49' 'None' '10.3.67.2/24' '10.3.67.1/24'
# node_4847-4134                                
echo "adding cluster edge node_4847-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_4847_4134' 'eth_4134_4847' '50' 'None' '10.3.68.2/24' '10.3.68.1/24'
# node_140647-4134                                
echo "adding cluster edge node_140647-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_140647_4134' 'eth_4134_140647' '51' 'None' '10.3.70.2/24' '10.3.70.1/24'
# node_142404-4134                                
echo "adding cluster edge node_142404-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_142404_4134' 'eth_4134_142404' '52' 'None' '10.3.72.2/24' '10.3.72.1/24'
# node_132147-4134                                
echo "adding cluster edge node_132147-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_132147_4134' 'eth_4134_132147' '53' 'None' '10.3.73.2/24' '10.3.73.1/24'
# node_134768-4134                                
echo "adding cluster edge node_134768-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_134768_4134' 'eth_4134_134768' '54' 'None' '10.3.74.2/24' '10.3.74.1/24'
# node_23724-4134                                
echo "adding cluster edge node_23724-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_23724_4134' 'eth_4134_23724' '55' 'None' '10.3.75.2/24' '10.3.75.1/24'
# node_4812-4134                                
echo "adding cluster edge node_4812-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_4812_4134' 'eth_4134_4812' '56' 'None' '10.3.76.2/24' '10.3.76.1/24'
# node_139019-4134                                
echo "adding cluster edge node_139019-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_139019_4134' 'eth_4134_139019' '57' 'None' '10.3.78.2/24' '10.3.78.1/24'
# node_137687-4134                                
echo "adding cluster edge node_137687-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_137687_4134' 'eth_4134_137687' '58' 'None' '10.3.79.2/24' '10.3.79.1/24'
# node_139018-4134                                
echo "adding cluster edge node_139018-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_139018_4134' 'eth_4134_139018' '59' 'None' '10.3.80.2/24' '10.3.80.1/24'
# node_139587-4134                                
echo "adding cluster edge node_139587-4134"                                
sleep 0.2                                
funCreateClusterV 'eth_139587_4134' 'eth_4134_139587' '60' 'None' '10.3.82.2/24' '10.3.82.1/24'
# node_131098-4766                                
echo "adding cluster edge node_131098-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_131098_4766' 'eth_4766_131098' '61' 'None' '10.2.244.2/24' '10.2.244.1/24'
# node_23599-9318                                
echo "adding cluster edge node_23599-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_23599_9318' 'eth_9318_23599' '62' 'None' '10.3.156.2/24' '10.3.156.1/24'
# node_23599-4766                                
echo "adding cluster edge node_23599-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_23599_4766' 'eth_4766_23599' '62' 'None' '10.2.247.2/24' '10.2.247.1/24'
# node_23596-1237                                
echo "adding cluster edge node_23596-1237"                                
sleep 0.2                                
funCreateClusterV 'eth_23596_1237' 'eth_1237_23596' '63' 'None' '10.3.182.1/24' '10.3.182.2/24'
# node_23596-4766                                
echo "adding cluster edge node_23596-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_23596_4766' 'eth_4766_23596' '63' 'None' '10.2.249.2/24' '10.2.249.1/24'
# node_23600-8763                                
echo "adding cluster edge node_23600-8763"                                
sleep 0.2                                
funCreateClusterV 'eth_23600_8763' 'eth_8763_23600' '64' 'None' '10.3.192.1/24' '10.3.192.2/24'
# node_23600-9318                                
echo "adding cluster edge node_23600-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_23600_9318' 'eth_9318_23600' '64' 'None' '10.3.158.2/24' '10.3.158.1/24'
# node_23600-4766                                
echo "adding cluster edge node_23600-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_23600_4766' 'eth_4766_23600' '64' 'None' '10.2.251.2/24' '10.2.251.1/24'
# node_9526-9318                                
echo "adding cluster edge node_9526-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9526_9318' 'eth_9318_9526' '65' 'None' '10.3.162.2/24' '10.3.162.1/24'
# node_9526-4766                                
echo "adding cluster edge node_9526-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9526_4766' 'eth_4766_9526' '65' 'None' '10.3.1.2/24' '10.3.1.1/24'
# node_45376-4766                                
echo "adding cluster edge node_45376-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_45376_4766' 'eth_4766_45376' '66' 'None' '10.3.2.2/24' '10.3.2.1/24'
# node_55633-4766                                
echo "adding cluster edge node_55633-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_55633_4766' 'eth_4766_55633' '67' 'None' '10.3.3.2/24' '10.3.3.1/24'
# node_9684-4766                                
echo "adding cluster edge node_9684-4766"                                
sleep 0.2                                
funCreateClusterV 'eth_9684_4766' 'eth_4766_9684' '68' 'None' '10.3.4.2/24' '10.3.4.1/24'
# node_45528-9498                                
echo "adding cluster edge node_45528-9498"                                
sleep 0.2                                
funCreateClusterV 'eth_45528_9498' 'eth_9498_45528' '69' 'None' '10.3.200.1/24' '10.3.200.2/24'
# node_45528-55410                                
echo "adding cluster edge node_45528-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_45528_55410' 'eth_55410_45528' '69' 'None' '10.3.177.2/24' '10.3.177.1/24'
# node_45528-9730                                
echo "adding host edge node_45528-9730"                                
sleep 0.2                                
funCreateV 'eth_45528_9730' 'eth_9730_45528' '69' '87' '10.3.201.1/24' '10.3.201.2/24'
# node_38266-55410                                
echo "adding cluster edge node_38266-55410"                                
sleep 0.2                                
funCreateClusterV 'eth_38266_55410' 'eth_55410_38266' '70' 'None' '10.3.178.2/24' '10.3.178.1/24'
# node_38266-55644                                
echo "adding cluster edge node_38266-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_38266_55644' 'eth_55644_38266' '70' 'None' '10.3.209.1/24' '10.3.209.2/24'
# node_132199-4775                                
echo "adding cluster edge node_132199-4775"                                
sleep 0.2                                
funCreateClusterV 'eth_132199_4775' 'eth_4775_132199' '71' 'None' '10.3.208.2/24' '10.3.208.1/24'
# node_45271-55644                                
echo "adding cluster edge node_45271-55644"                                
sleep 0.2                                
funCreateClusterV 'eth_45271_55644' 'eth_55644_45271' '72' 'None' '10.3.210.2/24' '10.3.210.1/24'
# node_1221-4637                                
echo "adding cluster edge node_1221-4637"                                
sleep 0.2                                
funCreateClusterV 'eth_1221_4637' 'eth_4637_1221' '73' 'None' '10.2.141.2/24' '10.2.141.1/24'
# node_1221-16509                                
echo "adding cluster edge node_1221-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_1221_16509' 'eth_16509_1221' '73' 'None' '10.3.213.2/24' '10.3.213.1/24'
# node_11537-16509                                
echo "adding cluster edge node_11537-16509"                                
sleep 0.2                                
funCreateClusterV 'eth_11537_16509' 'eth_16509_11537' '74' 'None' '10.3.130.1/24' '10.3.130.2/24'
# node_12389-8492                                
echo "adding cluster edge node_12389-8492"                                
sleep 0.2                                
funCreateClusterV 'eth_12389_8492' 'eth_8492_12389' '75' 'None' '10.0.234.2/24' '10.0.234.1/24'
# node_12389-18403                                
echo "adding cluster edge node_12389-18403"                                
sleep 0.2                                
funCreateClusterV 'eth_12389_18403' 'eth_18403_12389' '75' 'None' '10.3.222.2/24' '10.3.222.1/24'
# node_396982-15169                                
echo "adding cluster edge node_396982-15169"                                
sleep 0.2                                
funCreateClusterV 'eth_396982_15169' 'eth_15169_396982' '76' 'None' '10.3.233.1/24' '10.3.233.2/24'
# node_141750-9304                                
echo "adding cluster edge node_141750-9304"                                
sleep 0.2                                
funCreateClusterV 'eth_141750_9304' 'eth_9304_141750' '77' 'None' '10.2.162.2/24' '10.2.162.1/24'
# node_55329-23673                                
echo "adding cluster edge node_55329-23673"                                
sleep 0.2                                
funCreateClusterV 'eth_55329_23673' 'eth_23673_55329' '78' 'None' '10.2.4.2/24' '10.2.4.1/24'
# node_55329-9304                                
echo "adding cluster edge node_55329-9304"                                
sleep 0.2                                
funCreateClusterV 'eth_55329_9304' 'eth_9304_55329' '78' 'None' '10.2.167.2/24' '10.2.167.1/24'
# node_4621-4651                                
echo "adding cluster edge node_4621-4651"                                
sleep 0.2                                
funCreateClusterV 'eth_4621_4651' 'eth_4651_4621' '79' 'None' '10.2.243.2/24' '10.2.243.1/24'
# node_134809-18106                                
echo "adding cluster edge node_134809-18106"                                
sleep 0.2                                
funCreateClusterV 'eth_134809_18106' 'eth_18106_134809' '80' 'None' '10.0.185.2/24' '10.0.185.1/24'
# node_134809-4788                                
echo "adding cluster edge node_134809-4788"                                
sleep 0.2                                
funCreateClusterV 'eth_134809_4788' 'eth_4788_134809' '80' 'None' '10.3.120.2/24' '10.3.120.1/24'
# node_45996-9318                                
echo "adding cluster edge node_45996-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_45996_9318' 'eth_9318_45996' '81' 'None' '10.3.153.1/24' '10.3.153.2/24'
# node_131100-9318                                
echo "adding cluster edge node_131100-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_131100_9318' 'eth_9318_131100' '82' 'None' '10.3.155.2/24' '10.3.155.1/24'
# node_23588-9318                                
echo "adding cluster edge node_23588-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_23588_9318' 'eth_9318_23588' '83' 'None' '10.3.159.2/24' '10.3.159.1/24'
# node_9579-9318                                
echo "adding cluster edge node_9579-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9579_9318' 'eth_9318_9579' '84' 'None' '10.3.161.2/24' '10.3.161.1/24'
# node_9630-9318                                
echo "adding cluster edge node_9630-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9630_9318' 'eth_9318_9630' '85' 'None' '10.3.165.2/24' '10.3.165.1/24'
# node_9638-9318                                
echo "adding cluster edge node_9638-9318"                                
sleep 0.2                                
funCreateClusterV 'eth_9638_9318' 'eth_9318_9638' '86' 'None' '10.3.166.2/24' '10.3.166.1/24'
# node_9730-9498                                
echo "adding cluster edge node_9730-9498"                                
sleep 0.2                                
funCreateClusterV 'eth_9730_9498' 'eth_9498_9730' '87' 'None' '10.3.202.2/24' '10.3.202.1/24'
# node_38099-10158                                
echo "adding cluster edge node_38099-10158"                                
sleep 0.2                                
funCreateClusterV 'eth_38099_10158' 'eth_10158_38099' '88' 'None' '10.3.241.1/24' '10.3.241.2/24'
# node_134089-23673                                
echo "adding cluster edge node_134089-23673"                                
sleep 0.2                                
funCreateClusterV 'eth_134089_23673' 'eth_23673_134089' '89' 'None' '10.2.0.2/24' '10.2.0.1/24'
# node_4725-17676                                
echo "adding cluster edge node_4725-17676"                                
sleep 0.2                                
funCreateClusterV 'eth_4725_17676' 'eth_17676_4725' '90' 'None' '10.3.88.1/24' '10.3.88.2/24'
# node_4804-7474                                
echo "adding host edge node_4804-7474"                                
sleep 0.2                                
funCreateV 'eth_4804_7474' 'eth_7474_4804' '91' '92' '10.3.211.1/24' '10.3.211.2/24'
# node_4804-15412                                
echo "adding cluster edge node_4804-15412"                                
sleep 0.2                                
funCreateClusterV 'eth_4804_15412' 'eth_15412_4804' '91' 'None' '10.2.179.2/24' '10.2.179.1/24'
# node_4804-7473                                
echo "adding cluster edge node_4804-7473"                                
sleep 0.2                                
funCreateClusterV 'eth_4804_7473' 'eth_7473_4804' '91' 'None' '10.2.234.2/24' '10.2.234.1/24'
# node_7474-7473                                
echo "adding cluster edge node_7474-7473"                                
sleep 0.2                                
funCreateClusterV 'eth_7474_7473' 'eth_7473_7474' '92' 'None' '10.2.236.2/24' '10.2.236.1/24'
# node_7474-9723                                
echo "adding host edge node_7474-9723"                                
sleep 0.2                                
funCreateV 'eth_7474_9723' 'eth_9723_7474' '92' '99' '10.3.212.1/24' '10.3.212.2/24'
# node_2764-7545                                
echo "adding cluster edge node_2764-7545"                                
sleep 0.2                                
funCreateClusterV 'eth_2764_7545' 'eth_7545_2764' '93' 'None' '10.2.53.2/24' '10.2.53.1/24'
# node_137130-9583                                
echo "adding cluster edge node_137130-9583"                                
sleep 0.2                                
funCreateClusterV 'eth_137130_9583' 'eth_9583_137130' '94' 'None' '10.3.99.2/24' '10.3.99.1/24'
# node_140202-9583                                
echo "adding cluster edge node_140202-9583"                                
sleep 0.2                                
funCreateClusterV 'eth_140202_9583' 'eth_9583_140202' '95' 'None' '10.3.100.2/24' '10.3.100.1/24'
# node_396421-9583                                
echo "adding cluster edge node_396421-9583"                                
sleep 0.2                                
funCreateClusterV 'eth_396421_9583' 'eth_9583_396421' '96' 'None' '10.3.101.2/24' '10.3.101.1/24'
# node_9587-10089                                
echo "adding cluster edge node_9587-10089"                                
sleep 0.2                                
funCreateClusterV 'eth_9587_10089' 'eth_10089_9587' '97' 'None' '10.3.215.2/24' '10.3.215.1/24'
# node_9587-15932                                
echo "adding cluster edge node_9587-15932"                                
sleep 0.2                                
funCreateClusterV 'eth_9587_15932' 'eth_15932_9587' '97' 'None' '10.3.216.1/24' '10.3.216.2/24'
# node_24361-4538                                
echo "adding cluster edge node_24361-4538"                                
sleep 0.2                                
funCreateClusterV 'eth_24361_4538' 'eth_4538_24361' '98' 'None' '10.3.218.2/24' '10.3.218.1/24'
# node_9723-4826                                
echo "adding cluster edge node_9723-4826"                                
sleep 0.2                                
funCreateClusterV 'eth_9723_4826' 'eth_4826_9723' '99' 'None' '10.3.230.1/24' '10.3.230.2/24'