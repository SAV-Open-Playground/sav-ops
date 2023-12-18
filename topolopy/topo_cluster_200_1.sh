#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3356" "34224" "3549" "13335" "3303" "209" "1299" "174" "7018" "2519" "3257" "3741" "2914" "6762" "2516" "38040" "2152" "5511" "293" "4837" "1273" "1239" "6453" "31133" "64049" "6461" "3491" "6939" "9002" "37100" "3786" "5413" "701" "4134" "132203" "4766" "12552" "57866" "16735" "33891" "9607" "55410" "2497" "9680" "4775" "55644" "16509" "18403" "4809" "4637" "136907" "7303" "6663" "12479" "15169" "9505" "9957" "4657" "45974" "23764" "9304" "4651" "702" "4788" "9318" "8763" "9498" "3462" "58453" "9605" "10158" "20912" "49788" "18106" "11686" "22652" "8492" "23673" "1403" "17676" "7473" "3320" "3561" "7545" "15412" "9583" "24785" "64050" "10089" "15932" "4538" "4826" "6830" "20764" "1237" "20485" "7497" "9929" "7670" "23352" )
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
echo "adding host edge node_3356-6461"                                
sleep 0.2                                
funCreateV 'eth_3356_6461' 'eth_6461_3356' '0' '25' '10.0.24.1/24' '10.0.24.2/24'
# node_3356-3491                                
echo "adding host edge node_3356-3491"                                
sleep 0.2                                
funCreateV 'eth_3356_3491' 'eth_3491_3356' '0' '26' '10.0.25.1/24' '10.0.25.2/24'
# node_3356-6939                                
echo "adding host edge node_3356-6939"                                
sleep 0.2                                
funCreateV 'eth_3356_6939' 'eth_6939_3356' '0' '27' '10.0.26.1/24' '10.0.26.2/24'
# node_3356-9002                                
echo "adding host edge node_3356-9002"                                
sleep 0.2                                
funCreateV 'eth_3356_9002' 'eth_9002_3356' '0' '28' '10.0.27.1/24' '10.0.27.2/24'
# node_3356-37100                                
echo "adding host edge node_3356-37100"                                
sleep 0.2                                
funCreateV 'eth_3356_37100' 'eth_37100_3356' '0' '29' '10.0.28.1/24' '10.0.28.2/24'
# node_3356-3786                                
echo "adding host edge node_3356-3786"                                
sleep 0.2                                
funCreateV 'eth_3356_3786' 'eth_3786_3356' '0' '30' '10.0.29.1/24' '10.0.29.2/24'
# node_3356-5413                                
echo "adding host edge node_3356-5413"                                
sleep 0.2                                
funCreateV 'eth_3356_5413' 'eth_5413_3356' '0' '31' '10.0.30.1/24' '10.0.30.2/24'
# node_3356-701                                
echo "adding host edge node_3356-701"                                
sleep 0.2                                
funCreateV 'eth_3356_701' 'eth_701_3356' '0' '32' '10.0.31.1/24' '10.0.31.2/24'
# node_3356-4134                                
echo "adding host edge node_3356-4134"                                
sleep 0.2                                
funCreateV 'eth_3356_4134' 'eth_4134_3356' '0' '33' '10.0.32.1/24' '10.0.32.2/24'
# node_3356-132203                                
echo "adding host edge node_3356-132203"                                
sleep 0.2                                
funCreateV 'eth_3356_132203' 'eth_132203_3356' '0' '34' '10.0.33.1/24' '10.0.33.2/24'
# node_3356-4766                                
echo "adding host edge node_3356-4766"                                
sleep 0.2                                
funCreateV 'eth_3356_4766' 'eth_4766_3356' '0' '35' '10.0.34.1/24' '10.0.34.2/24'
# node_3356-12552                                
echo "adding host edge node_3356-12552"                                
sleep 0.2                                
funCreateV 'eth_3356_12552' 'eth_12552_3356' '0' '36' '10.0.35.1/24' '10.0.35.2/24'
# node_3356-57866                                
echo "adding host edge node_3356-57866"                                
sleep 0.2                                
funCreateV 'eth_3356_57866' 'eth_57866_3356' '0' '37' '10.0.36.1/24' '10.0.36.2/24'
# node_3356-16735                                
echo "adding host edge node_3356-16735"                                
sleep 0.2                                
funCreateV 'eth_3356_16735' 'eth_16735_3356' '0' '38' '10.0.37.1/24' '10.0.37.2/24'
# node_3356-33891                                
echo "adding host edge node_3356-33891"                                
sleep 0.2                                
funCreateV 'eth_3356_33891' 'eth_33891_3356' '0' '39' '10.0.38.1/24' '10.0.38.2/24'
# node_3356-9607                                
echo "adding host edge node_3356-9607"                                
sleep 0.2                                
funCreateV 'eth_3356_9607' 'eth_9607_3356' '0' '40' '10.0.39.1/24' '10.0.39.2/24'
# node_3356-55410                                
echo "adding host edge node_3356-55410"                                
sleep 0.2                                
funCreateV 'eth_3356_55410' 'eth_55410_3356' '0' '41' '10.0.40.1/24' '10.0.40.2/24'
# node_3356-2497                                
echo "adding host edge node_3356-2497"                                
sleep 0.2                                
funCreateV 'eth_3356_2497' 'eth_2497_3356' '0' '42' '10.0.41.1/24' '10.0.41.2/24'
# node_3356-9680                                
echo "adding host edge node_3356-9680"                                
sleep 0.2                                
funCreateV 'eth_3356_9680' 'eth_9680_3356' '0' '43' '10.0.42.1/24' '10.0.42.2/24'
# node_3356-4775                                
echo "adding host edge node_3356-4775"                                
sleep 0.2                                
funCreateV 'eth_3356_4775' 'eth_4775_3356' '0' '44' '10.0.43.1/24' '10.0.43.2/24'
# node_3356-55644                                
echo "adding host edge node_3356-55644"                                
sleep 0.2                                
funCreateV 'eth_3356_55644' 'eth_55644_3356' '0' '45' '10.0.44.1/24' '10.0.44.2/24'
# node_3356-16509                                
echo "adding host edge node_3356-16509"                                
sleep 0.2                                
funCreateV 'eth_3356_16509' 'eth_16509_3356' '0' '46' '10.0.45.1/24' '10.0.45.2/24'
# node_3356-18403                                
echo "adding host edge node_3356-18403"                                
sleep 0.2                                
funCreateV 'eth_3356_18403' 'eth_18403_3356' '0' '47' '10.0.46.1/24' '10.0.46.2/24'
# node_3356-4809                                
echo "adding host edge node_3356-4809"                                
sleep 0.2                                
funCreateV 'eth_3356_4809' 'eth_4809_3356' '0' '48' '10.0.47.1/24' '10.0.47.2/24'
# node_3356-4637                                
echo "adding host edge node_3356-4637"                                
sleep 0.2                                
funCreateV 'eth_3356_4637' 'eth_4637_3356' '0' '49' '10.0.48.1/24' '10.0.48.2/24'
# node_3356-136907                                
echo "adding host edge node_3356-136907"                                
sleep 0.2                                
funCreateV 'eth_3356_136907' 'eth_136907_3356' '0' '50' '10.0.49.1/24' '10.0.49.2/24'
# node_3356-7303                                
echo "adding host edge node_3356-7303"                                
sleep 0.2                                
funCreateV 'eth_3356_7303' 'eth_7303_3356' '0' '51' '10.0.50.1/24' '10.0.50.2/24'
# node_3356-6663                                
echo "adding host edge node_3356-6663"                                
sleep 0.2                                
funCreateV 'eth_3356_6663' 'eth_6663_3356' '0' '52' '10.0.51.1/24' '10.0.51.2/24'
# node_3356-12479                                
echo "adding host edge node_3356-12479"                                
sleep 0.2                                
funCreateV 'eth_3356_12479' 'eth_12479_3356' '0' '53' '10.0.52.1/24' '10.0.52.2/24'
# node_3356-15169                                
echo "adding host edge node_3356-15169"                                
sleep 0.2                                
funCreateV 'eth_3356_15169' 'eth_15169_3356' '0' '54' '10.0.53.1/24' '10.0.53.2/24'
# node_3356-9505                                
echo "adding host edge node_3356-9505"                                
sleep 0.2                                
funCreateV 'eth_3356_9505' 'eth_9505_3356' '0' '55' '10.0.54.1/24' '10.0.54.2/24'
# node_3356-9957                                
echo "adding host edge node_3356-9957"                                
sleep 0.2                                
funCreateV 'eth_3356_9957' 'eth_9957_3356' '0' '56' '10.0.55.1/24' '10.0.55.2/24'
# node_3356-4657                                
echo "adding host edge node_3356-4657"                                
sleep 0.2                                
funCreateV 'eth_3356_4657' 'eth_4657_3356' '0' '57' '10.0.56.1/24' '10.0.56.2/24'
# node_3356-45974                                
echo "adding host edge node_3356-45974"                                
sleep 0.2                                
funCreateV 'eth_3356_45974' 'eth_45974_3356' '0' '58' '10.0.57.1/24' '10.0.57.2/24'
# node_3356-23764                                
echo "adding host edge node_3356-23764"                                
sleep 0.2                                
funCreateV 'eth_3356_23764' 'eth_23764_3356' '0' '59' '10.0.58.1/24' '10.0.58.2/24'
# node_34224-13335                                
echo "adding host edge node_34224-13335"                                
sleep 0.2                                
funCreateV 'eth_34224_13335' 'eth_13335_34224' '1' '3' '10.0.59.1/24' '10.0.59.2/24'
# node_34224-6939                                
echo "adding host edge node_34224-6939"                                
sleep 0.2                                
funCreateV 'eth_34224_6939' 'eth_6939_34224' '1' '27' '10.0.60.1/24' '10.0.60.2/24'
# node_34224-9304                                
echo "adding host edge node_34224-9304"                                
sleep 0.2                                
funCreateV 'eth_34224_9304' 'eth_9304_34224' '1' '60' '10.0.61.1/24' '10.0.61.2/24'
# node_34224-38040                                
echo "adding host edge node_34224-38040"                                
sleep 0.2                                
funCreateV 'eth_34224_38040' 'eth_38040_34224' '1' '15' '10.0.62.1/24' '10.0.62.2/24'
# node_34224-4651                                
echo "adding host edge node_34224-4651"                                
sleep 0.2                                
funCreateV 'eth_34224_4651' 'eth_4651_34224' '1' '61' '10.0.63.1/24' '10.0.63.2/24'
# node_34224-6453                                
echo "adding host edge node_34224-6453"                                
sleep 0.2                                
funCreateV 'eth_34224_6453' 'eth_6453_34224' '1' '22' '10.0.64.1/24' '10.0.64.2/24'
# node_34224-702                                
echo "adding host edge node_34224-702"                                
sleep 0.2                                
funCreateV 'eth_34224_702' 'eth_702_34224' '1' '62' '10.0.65.1/24' '10.0.65.2/24'
# node_34224-4788                                
echo "adding host edge node_34224-4788"                                
sleep 0.2                                
funCreateV 'eth_34224_4788' 'eth_4788_34224' '1' '63' '10.0.66.1/24' '10.0.66.2/24'
# node_34224-9318                                
echo "adding host edge node_34224-9318"                                
sleep 0.2                                
funCreateV 'eth_34224_9318' 'eth_9318_34224' '1' '64' '10.0.67.1/24' '10.0.67.2/24'
# node_34224-132203                                
echo "adding host edge node_34224-132203"                                
sleep 0.2                                
funCreateV 'eth_34224_132203' 'eth_132203_34224' '1' '34' '10.0.68.1/24' '10.0.68.2/24'
# node_34224-8763                                
echo "adding host edge node_34224-8763"                                
sleep 0.2                                
funCreateV 'eth_34224_8763' 'eth_8763_34224' '1' '65' '10.0.69.1/24' '10.0.69.2/24'
# node_34224-9498                                
echo "adding host edge node_34224-9498"                                
sleep 0.2                                
funCreateV 'eth_34224_9498' 'eth_9498_34224' '1' '66' '10.0.70.1/24' '10.0.70.2/24'
# node_34224-9002                                
echo "adding host edge node_34224-9002"                                
sleep 0.2                                
funCreateV 'eth_34224_9002' 'eth_9002_34224' '1' '28' '10.0.71.1/24' '10.0.71.2/24'
# node_34224-6762                                
echo "adding host edge node_34224-6762"                                
sleep 0.2                                
funCreateV 'eth_34224_6762' 'eth_6762_34224' '1' '13' '10.0.72.1/24' '10.0.72.2/24'
# node_34224-3462                                
echo "adding host edge node_34224-3462"                                
sleep 0.2                                
funCreateV 'eth_34224_3462' 'eth_3462_34224' '1' '67' '10.0.73.1/24' '10.0.73.2/24'
# node_34224-4775                                
echo "adding host edge node_34224-4775"                                
sleep 0.2                                
funCreateV 'eth_34224_4775' 'eth_4775_34224' '1' '44' '10.0.74.1/24' '10.0.74.2/24'
# node_34224-58453                                
echo "adding host edge node_34224-58453"                                
sleep 0.2                                
funCreateV 'eth_34224_58453' 'eth_58453_34224' '1' '68' '10.0.75.1/24' '10.0.75.2/24'
# node_34224-23764                                
echo "adding host edge node_34224-23764"                                
sleep 0.2                                
funCreateV 'eth_34224_23764' 'eth_23764_34224' '1' '59' '10.0.76.1/24' '10.0.76.2/24'
# node_34224-18403                                
echo "adding host edge node_34224-18403"                                
sleep 0.2                                
funCreateV 'eth_34224_18403' 'eth_18403_34224' '1' '47' '10.0.77.1/24' '10.0.77.2/24'
# node_34224-9605                                
echo "adding host edge node_34224-9605"                                
sleep 0.2                                
funCreateV 'eth_34224_9605' 'eth_9605_34224' '1' '69' '10.0.78.1/24' '10.0.78.2/24'
# node_34224-6663                                
echo "adding host edge node_34224-6663"                                
sleep 0.2                                
funCreateV 'eth_34224_6663' 'eth_6663_34224' '1' '52' '10.0.79.1/24' '10.0.79.2/24'
# node_34224-15169                                
echo "adding host edge node_34224-15169"                                
sleep 0.2                                
funCreateV 'eth_34224_15169' 'eth_15169_34224' '1' '54' '10.0.80.1/24' '10.0.80.2/24'
# node_34224-10158                                
echo "adding host edge node_34224-10158"                                
sleep 0.2                                
funCreateV 'eth_34224_10158' 'eth_10158_34224' '1' '70' '10.0.81.1/24' '10.0.81.2/24'
# node_3549-4775                                
echo "adding host edge node_3549-4775"                                
sleep 0.2                                
funCreateV 'eth_3549_4775' 'eth_4775_3549' '2' '44' '10.0.159.1/24' '10.0.159.2/24'
# node_13335-7018                                
echo "adding host edge node_13335-7018"                                
sleep 0.2                                
funCreateV 'eth_13335_7018' 'eth_7018_13335' '3' '8' '10.0.82.1/24' '10.0.82.2/24'
# node_13335-20912                                
echo "adding host edge node_13335-20912"                                
sleep 0.2                                
funCreateV 'eth_13335_20912' 'eth_20912_13335' '3' '71' '10.0.83.1/24' '10.0.83.2/24'
# node_13335-3257                                
echo "adding host edge node_13335-3257"                                
sleep 0.2                                
funCreateV 'eth_13335_3257' 'eth_3257_13335' '3' '10' '10.0.84.1/24' '10.0.84.2/24'
# node_13335-49788                                
echo "adding host edge node_13335-49788"                                
sleep 0.2                                
funCreateV 'eth_13335_49788' 'eth_49788_13335' '3' '72' '10.0.85.1/24' '10.0.85.2/24'
# node_13335-3741                                
echo "adding host edge node_13335-3741"                                
sleep 0.2                                
funCreateV 'eth_13335_3741' 'eth_3741_13335' '3' '11' '10.0.86.1/24' '10.0.86.2/24'
# node_13335-18106                                
echo "adding host edge node_13335-18106"                                
sleep 0.2                                
funCreateV 'eth_13335_18106' 'eth_18106_13335' '3' '73' '10.0.87.1/24' '10.0.87.2/24'
# node_13335-11686                                
echo "adding host edge node_13335-11686"                                
sleep 0.2                                
funCreateV 'eth_13335_11686' 'eth_11686_13335' '3' '74' '10.0.88.1/24' '10.0.88.2/24'
# node_13335-22652                                
echo "adding host edge node_13335-22652"                                
sleep 0.2                                
funCreateV 'eth_13335_22652' 'eth_22652_13335' '3' '75' '10.0.89.1/24' '10.0.89.2/24'
# node_13335-57866                                
echo "adding host edge node_13335-57866"                                
sleep 0.2                                
funCreateV 'eth_13335_57866' 'eth_57866_13335' '3' '37' '10.0.90.1/24' '10.0.90.2/24'
# node_13335-8492                                
echo "adding host edge node_13335-8492"                                
sleep 0.2                                
funCreateV 'eth_13335_8492' 'eth_8492_13335' '3' '76' '10.0.91.1/24' '10.0.91.2/24'
# node_13335-1299                                
echo "adding host edge node_13335-1299"                                
sleep 0.2                                
funCreateV 'eth_13335_1299' 'eth_1299_13335' '3' '6' '10.0.92.1/24' '10.0.92.2/24'
# node_13335-2152                                
echo "adding host edge node_13335-2152"                                
sleep 0.2                                
funCreateV 'eth_13335_2152' 'eth_2152_13335' '3' '16' '10.0.93.1/24' '10.0.93.2/24'
# node_13335-6939                                
echo "adding host edge node_13335-6939"                                
sleep 0.2                                
funCreateV 'eth_13335_6939' 'eth_6939_13335' '3' '27' '10.0.94.1/24' '10.0.94.2/24'
# node_13335-2497                                
echo "adding host edge node_13335-2497"                                
sleep 0.2                                
funCreateV 'eth_13335_2497' 'eth_2497_13335' '3' '42' '10.0.95.1/24' '10.0.95.2/24'
# node_13335-293                                
echo "adding host edge node_13335-293"                                
sleep 0.2                                
funCreateV 'eth_13335_293' 'eth_293_13335' '3' '18' '10.0.96.1/24' '10.0.96.2/24'
# node_13335-5413                                
echo "adding host edge node_13335-5413"                                
sleep 0.2                                
funCreateV 'eth_13335_5413' 'eth_5413_13335' '3' '31' '10.0.97.1/24' '10.0.97.2/24'
# node_13335-2914                                
echo "adding host edge node_13335-2914"                                
sleep 0.2                                
funCreateV 'eth_13335_2914' 'eth_2914_13335' '3' '12' '10.0.98.1/24' '10.0.98.2/24'
# node_13335-23673                                
echo "adding host edge node_13335-23673"                                
sleep 0.2                                
funCreateV 'eth_13335_23673' 'eth_23673_13335' '3' '77' '10.0.99.1/24' '10.0.99.2/24'
# node_13335-1403                                
echo "adding host edge node_13335-1403"                                
sleep 0.2                                
funCreateV 'eth_13335_1403' 'eth_1403_13335' '3' '78' '10.0.100.1/24' '10.0.100.2/24'
# node_13335-1239                                
echo "adding host edge node_13335-1239"                                
sleep 0.2                                
funCreateV 'eth_13335_1239' 'eth_1239_13335' '3' '21' '10.0.101.1/24' '10.0.101.2/24'
# node_3303-6939                                
echo "adding host edge node_3303-6939"                                
sleep 0.2                                
funCreateV 'eth_3303_6939' 'eth_6939_3303' '4' '27' '10.1.29.1/24' '10.1.29.2/24'
# node_3303-9304                                
echo "adding host edge node_3303-9304"                                
sleep 0.2                                
funCreateV 'eth_3303_9304' 'eth_9304_3303' '4' '60' '10.1.30.1/24' '10.1.30.2/24'
# node_3303-2497                                
echo "adding host edge node_3303-2497"                                
sleep 0.2                                
funCreateV 'eth_3303_2497' 'eth_2497_3303' '4' '42' '10.1.31.1/24' '10.1.31.2/24'
# node_3303-38040                                
echo "adding host edge node_3303-38040"                                
sleep 0.2                                
funCreateV 'eth_3303_38040' 'eth_38040_3303' '4' '15' '10.1.32.1/24' '10.1.32.2/24'
# node_3303-4651                                
echo "adding host edge node_3303-4651"                                
sleep 0.2                                
funCreateV 'eth_3303_4651' 'eth_4651_3303' '4' '61' '10.1.33.1/24' '10.1.33.2/24'
# node_3303-4837                                
echo "adding host edge node_3303-4837"                                
sleep 0.2                                
funCreateV 'eth_3303_4837' 'eth_4837_3303' '4' '19' '10.1.34.1/24' '10.1.34.2/24'
# node_3303-6453                                
echo "adding host edge node_3303-6453"                                
sleep 0.2                                
funCreateV 'eth_3303_6453' 'eth_6453_3303' '4' '22' '10.1.35.1/24' '10.1.35.2/24'
# node_3303-17676                                
echo "adding host edge node_3303-17676"                                
sleep 0.2                                
funCreateV 'eth_3303_17676' 'eth_17676_3303' '4' '79' '10.1.36.1/24' '10.1.36.2/24'
# node_3303-2914                                
echo "adding host edge node_3303-2914"                                
sleep 0.2                                
funCreateV 'eth_3303_2914' 'eth_2914_3303' '4' '12' '10.1.37.1/24' '10.1.37.2/24'
# node_3303-174                                
echo "adding host edge node_3303-174"                                
sleep 0.2                                
funCreateV 'eth_3303_174' 'eth_174_3303' '4' '7' '10.1.38.1/24' '10.1.38.2/24'
# node_3303-7473                                
echo "adding host edge node_3303-7473"                                
sleep 0.2                                
funCreateV 'eth_3303_7473' 'eth_7473_3303' '4' '80' '10.1.39.1/24' '10.1.39.2/24'
# node_3303-3491                                
echo "adding host edge node_3303-3491"                                
sleep 0.2                                
funCreateV 'eth_3303_3491' 'eth_3491_3303' '4' '26' '10.1.40.1/24' '10.1.40.2/24'
# node_3303-4788                                
echo "adding host edge node_3303-4788"                                
sleep 0.2                                
funCreateV 'eth_3303_4788' 'eth_4788_3303' '4' '63' '10.1.41.1/24' '10.1.41.2/24'
# node_3303-64049                                
echo "adding host edge node_3303-64049"                                
sleep 0.2                                
funCreateV 'eth_3303_64049' 'eth_64049_3303' '4' '24' '10.1.42.1/24' '10.1.42.2/24'
# node_3303-3786                                
echo "adding host edge node_3303-3786"                                
sleep 0.2                                
funCreateV 'eth_3303_3786' 'eth_3786_3303' '4' '30' '10.1.43.1/24' '10.1.43.2/24'
# node_3303-9318                                
echo "adding host edge node_3303-9318"                                
sleep 0.2                                
funCreateV 'eth_3303_9318' 'eth_9318_3303' '4' '64' '10.1.44.1/24' '10.1.44.2/24'
# node_3303-4134                                
echo "adding host edge node_3303-4134"                                
sleep 0.2                                
funCreateV 'eth_3303_4134' 'eth_4134_3303' '4' '33' '10.1.45.1/24' '10.1.45.2/24'
# node_3303-132203                                
echo "adding host edge node_3303-132203"                                
sleep 0.2                                
funCreateV 'eth_3303_132203' 'eth_132203_3303' '4' '34' '10.1.46.1/24' '10.1.46.2/24'
# node_3303-4766                                
echo "adding host edge node_3303-4766"                                
sleep 0.2                                
funCreateV 'eth_3303_4766' 'eth_4766_3303' '4' '35' '10.1.47.1/24' '10.1.47.2/24'
# node_3303-8763                                
echo "adding host edge node_3303-8763"                                
sleep 0.2                                
funCreateV 'eth_3303_8763' 'eth_8763_3303' '4' '65' '10.1.48.1/24' '10.1.48.2/24'
# node_3303-4637                                
echo "adding host edge node_3303-4637"                                
sleep 0.2                                
funCreateV 'eth_3303_4637' 'eth_4637_3303' '4' '49' '10.1.49.1/24' '10.1.49.2/24'
# node_3303-1273                                
echo "adding host edge node_3303-1273"                                
sleep 0.2                                
funCreateV 'eth_3303_1273' 'eth_1273_3303' '4' '20' '10.1.50.1/24' '10.1.50.2/24'
# node_3303-9498                                
echo "adding host edge node_3303-9498"                                
sleep 0.2                                
funCreateV 'eth_3303_9498' 'eth_9498_3303' '4' '66' '10.1.51.1/24' '10.1.51.2/24'
# node_3303-9002                                
echo "adding host edge node_3303-9002"                                
sleep 0.2                                
funCreateV 'eth_3303_9002' 'eth_9002_3303' '4' '28' '10.1.52.1/24' '10.1.52.2/24'
# node_3303-6461                                
echo "adding host edge node_3303-6461"                                
sleep 0.2                                
funCreateV 'eth_3303_6461' 'eth_6461_3303' '4' '25' '10.1.53.1/24' '10.1.53.2/24'
# node_3303-23764                                
echo "adding host edge node_3303-23764"                                
sleep 0.2                                
funCreateV 'eth_3303_23764' 'eth_23764_3303' '4' '59' '10.1.54.1/24' '10.1.54.2/24'
# node_3303-58453                                
echo "adding host edge node_3303-58453"                                
sleep 0.2                                
funCreateV 'eth_3303_58453' 'eth_58453_3303' '4' '68' '10.1.55.1/24' '10.1.55.2/24'
# node_3303-3257                                
echo "adding host edge node_3303-3257"                                
sleep 0.2                                
funCreateV 'eth_3303_3257' 'eth_3257_3303' '4' '10' '10.0.149.2/24' '10.0.149.1/24'
# node_3303-3320                                
echo "adding host edge node_3303-3320"                                
sleep 0.2                                
funCreateV 'eth_3303_3320' 'eth_3320_3303' '4' '81' '10.1.56.1/24' '10.1.56.2/24'
# node_3303-15169                                
echo "adding host edge node_3303-15169"                                
sleep 0.2                                
funCreateV 'eth_3303_15169' 'eth_15169_3303' '4' '54' '10.1.57.1/24' '10.1.57.2/24'
# node_209-3561                                
echo "adding host edge node_209-3561"                                
sleep 0.2                                
funCreateV 'eth_209_3561' 'eth_3561_209' '5' '82' '10.1.183.2/24' '10.1.183.1/24'
# node_1299-7018                                
echo "adding host edge node_1299-7018"                                
sleep 0.2                                
funCreateV 'eth_1299_7018' 'eth_7018_1299' '6' '8' '10.0.102.2/24' '10.0.102.1/24'
# node_1299-7545                                
echo "adding host edge node_1299-7545"                                
sleep 0.2                                
funCreateV 'eth_1299_7545' 'eth_7545_1299' '6' '83' '10.0.236.1/24' '10.0.236.2/24'
# node_1299-3257                                
echo "adding host edge node_1299-3257"                                
sleep 0.2                                
funCreateV 'eth_1299_3257' 'eth_3257_1299' '6' '10' '10.0.125.2/24' '10.0.125.1/24'
# node_1299-57866                                
echo "adding host edge node_1299-57866"                                
sleep 0.2                                
funCreateV 'eth_1299_57866' 'eth_57866_1299' '6' '37' '10.0.220.2/24' '10.0.220.1/24'
# node_1299-2519                                
echo "adding host edge node_1299-2519"                                
sleep 0.2                                
funCreateV 'eth_1299_2519' 'eth_2519_1299' '6' '9' '10.0.237.1/24' '10.0.237.2/24'
# node_1299-22652                                
echo "adding host edge node_1299-22652"                                
sleep 0.2                                
funCreateV 'eth_1299_22652' 'eth_22652_1299' '6' '75' '10.0.214.2/24' '10.0.214.1/24'
# node_1299-1403                                
echo "adding host edge node_1299-1403"                                
sleep 0.2                                
funCreateV 'eth_1299_1403' 'eth_1403_1299' '6' '78' '10.0.238.1/24' '10.0.238.2/24'
# node_1299-15412                                
echo "adding host edge node_1299-15412"                                
sleep 0.2                                
funCreateV 'eth_1299_15412' 'eth_15412_1299' '6' '84' '10.0.239.1/24' '10.0.239.2/24'
# node_1299-2497                                
echo "adding host edge node_1299-2497"                                
sleep 0.2                                
funCreateV 'eth_1299_2497' 'eth_2497_1299' '6' '42' '10.0.240.1/24' '10.0.240.2/24'
# node_1299-38040                                
echo "adding host edge node_1299-38040"                                
sleep 0.2                                
funCreateV 'eth_1299_38040' 'eth_38040_1299' '6' '15' '10.0.241.1/24' '10.0.241.2/24'
# node_1299-7473                                
echo "adding host edge node_1299-7473"                                
sleep 0.2                                
funCreateV 'eth_1299_7473' 'eth_7473_1299' '6' '80' '10.0.242.1/24' '10.0.242.2/24'
# node_1299-49788                                
echo "adding host edge node_1299-49788"                                
sleep 0.2                                
funCreateV 'eth_1299_49788' 'eth_49788_1299' '6' '72' '10.0.157.2/24' '10.0.157.1/24'
# node_1299-4837                                
echo "adding host edge node_1299-4837"                                
sleep 0.2                                
funCreateV 'eth_1299_4837' 'eth_4837_1299' '6' '19' '10.0.243.1/24' '10.0.243.2/24'
# node_1299-5413                                
echo "adding host edge node_1299-5413"                                
sleep 0.2                                
funCreateV 'eth_1299_5413' 'eth_5413_1299' '6' '31' '10.0.244.1/24' '10.0.244.2/24'
# node_1299-2914                                
echo "adding host edge node_1299-2914"                                
sleep 0.2                                
funCreateV 'eth_1299_2914' 'eth_2914_1299' '6' '12' '10.0.245.1/24' '10.0.245.2/24'
# node_1299-17676                                
echo "adding host edge node_1299-17676"                                
sleep 0.2                                
funCreateV 'eth_1299_17676' 'eth_17676_1299' '6' '79' '10.0.246.1/24' '10.0.246.2/24'
# node_1299-9583                                
echo "adding host edge node_1299-9583"                                
sleep 0.2                                
funCreateV 'eth_1299_9583' 'eth_9583_1299' '6' '85' '10.0.247.1/24' '10.0.247.2/24'
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
echo "adding host edge node_1299-6939"                                
sleep 0.2                                
funCreateV 'eth_1299_6939' 'eth_6939_1299' '6' '27' '10.0.251.1/24' '10.0.251.2/24'
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
echo "adding host edge node_1299-6461"                                
sleep 0.2                                
funCreateV 'eth_1299_6461' 'eth_6461_1299' '6' '25' '10.1.0.1/24' '10.1.0.2/24'
# node_1299-3491                                
echo "adding host edge node_1299-3491"                                
sleep 0.2                                
funCreateV 'eth_1299_3491' 'eth_3491_1299' '6' '26' '10.1.1.1/24' '10.1.1.2/24'
# node_1299-4788                                
echo "adding host edge node_1299-4788"                                
sleep 0.2                                
funCreateV 'eth_1299_4788' 'eth_4788_1299' '6' '63' '10.1.2.1/24' '10.1.2.2/24'
# node_1299-37100                                
echo "adding host edge node_1299-37100"                                
sleep 0.2                                
funCreateV 'eth_1299_37100' 'eth_37100_1299' '6' '29' '10.1.3.1/24' '10.1.3.2/24'
# node_1299-9318                                
echo "adding host edge node_1299-9318"                                
sleep 0.2                                
funCreateV 'eth_1299_9318' 'eth_9318_1299' '6' '64' '10.1.4.1/24' '10.1.4.2/24'
# node_1299-4134                                
echo "adding host edge node_1299-4134"                                
sleep 0.2                                
funCreateV 'eth_1299_4134' 'eth_4134_1299' '6' '33' '10.1.5.1/24' '10.1.5.2/24'
# node_1299-132203                                
echo "adding host edge node_1299-132203"                                
sleep 0.2                                
funCreateV 'eth_1299_132203' 'eth_132203_1299' '6' '34' '10.1.6.1/24' '10.1.6.2/24'
# node_1299-4766                                
echo "adding host edge node_1299-4766"                                
sleep 0.2                                
funCreateV 'eth_1299_4766' 'eth_4766_1299' '6' '35' '10.1.7.1/24' '10.1.7.2/24'
# node_1299-24785                                
echo "adding host edge node_1299-24785"                                
sleep 0.2                                
funCreateV 'eth_1299_24785' 'eth_24785_1299' '6' '86' '10.1.8.1/24' '10.1.8.2/24'
# node_1299-9498                                
echo "adding host edge node_1299-9498"                                
sleep 0.2                                
funCreateV 'eth_1299_9498' 'eth_9498_1299' '6' '66' '10.1.9.1/24' '10.1.9.2/24'
# node_1299-64050                                
echo "adding host edge node_1299-64050"                                
sleep 0.2                                
funCreateV 'eth_1299_64050' 'eth_64050_1299' '6' '87' '10.1.10.1/24' '10.1.10.2/24'
# node_1299-4657                                
echo "adding host edge node_1299-4657"                                
sleep 0.2                                
funCreateV 'eth_1299_4657' 'eth_4657_1299' '6' '57' '10.1.11.1/24' '10.1.11.2/24'
# node_1299-9002                                
echo "adding host edge node_1299-9002"                                
sleep 0.2                                
funCreateV 'eth_1299_9002' 'eth_9002_1299' '6' '28' '10.1.12.1/24' '10.1.12.2/24'
# node_1299-9680                                
echo "adding host edge node_1299-9680"                                
sleep 0.2                                
funCreateV 'eth_1299_9680' 'eth_9680_1299' '6' '43' '10.1.13.1/24' '10.1.13.2/24'
# node_1299-4775                                
echo "adding host edge node_1299-4775"                                
sleep 0.2                                
funCreateV 'eth_1299_4775' 'eth_4775_1299' '6' '44' '10.1.14.1/24' '10.1.14.2/24'
# node_1299-16509                                
echo "adding host edge node_1299-16509"                                
sleep 0.2                                
funCreateV 'eth_1299_16509' 'eth_16509_1299' '6' '46' '10.1.15.1/24' '10.1.15.2/24'
# node_1299-10089                                
echo "adding host edge node_1299-10089"                                
sleep 0.2                                
funCreateV 'eth_1299_10089' 'eth_10089_1299' '6' '88' '10.1.16.1/24' '10.1.16.2/24'
# node_1299-15932                                
echo "adding host edge node_1299-15932"                                
sleep 0.2                                
funCreateV 'eth_1299_15932' 'eth_15932_1299' '6' '89' '10.1.17.1/24' '10.1.17.2/24'
# node_1299-4538                                
echo "adding host edge node_1299-4538"                                
sleep 0.2                                
funCreateV 'eth_1299_4538' 'eth_4538_1299' '6' '90' '10.1.18.1/24' '10.1.18.2/24'
# node_1299-23764                                
echo "adding host edge node_1299-23764"                                
sleep 0.2                                
funCreateV 'eth_1299_23764' 'eth_23764_1299' '6' '59' '10.1.19.1/24' '10.1.19.2/24'
# node_1299-18403                                
echo "adding host edge node_1299-18403"                                
sleep 0.2                                
funCreateV 'eth_1299_18403' 'eth_18403_1299' '6' '47' '10.1.20.1/24' '10.1.20.2/24'
# node_1299-58453                                
echo "adding host edge node_1299-58453"                                
sleep 0.2                                
funCreateV 'eth_1299_58453' 'eth_58453_1299' '6' '68' '10.1.21.1/24' '10.1.21.2/24'
# node_1299-4809                                
echo "adding host edge node_1299-4809"                                
sleep 0.2                                
funCreateV 'eth_1299_4809' 'eth_4809_1299' '6' '48' '10.1.22.1/24' '10.1.22.2/24'
# node_1299-4637                                
echo "adding host edge node_1299-4637"                                
sleep 0.2                                
funCreateV 'eth_1299_4637' 'eth_4637_1299' '6' '49' '10.1.23.1/24' '10.1.23.2/24'
# node_1299-4826                                
echo "adding host edge node_1299-4826"                                
sleep 0.2                                
funCreateV 'eth_1299_4826' 'eth_4826_1299' '6' '91' '10.1.24.1/24' '10.1.24.2/24'
# node_1299-6663                                
echo "adding host edge node_1299-6663"                                
sleep 0.2                                
funCreateV 'eth_1299_6663' 'eth_6663_1299' '6' '52' '10.1.25.1/24' '10.1.25.2/24'
# node_1299-5511                                
echo "adding host edge node_1299-5511"                                
sleep 0.2                                
funCreateV 'eth_1299_5511' 'eth_5511_1299' '6' '17' '10.1.26.1/24' '10.1.26.2/24'
# node_1299-15169                                
echo "adding host edge node_1299-15169"                                
sleep 0.2                                
funCreateV 'eth_1299_15169' 'eth_15169_1299' '6' '54' '10.1.27.1/24' '10.1.27.2/24'
# node_1299-9505                                
echo "adding host edge node_1299-9505"                                
sleep 0.2                                
funCreateV 'eth_1299_9505' 'eth_9505_1299' '6' '55' '10.1.28.1/24' '10.1.28.2/24'
# node_174-7545                                
echo "adding host edge node_174-7545"                                
sleep 0.2                                
funCreateV 'eth_174_7545' 'eth_7545_174' '7' '83' '10.2.54.2/24' '10.2.54.1/24'
# node_174-11686                                
echo "adding host edge node_174-11686"                                
sleep 0.2                                
funCreateV 'eth_174_11686' 'eth_11686_174' '7' '74' '10.0.209.2/24' '10.0.209.1/24'
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
# node_174-49788                                
echo "adding host edge node_174-49788"                                
sleep 0.2                                
funCreateV 'eth_174_49788' 'eth_49788_174' '7' '72' '10.0.158.2/24' '10.0.158.1/24'
# node_174-3491                                
echo "adding host edge node_174-3491"                                
sleep 0.2                                
funCreateV 'eth_174_3491' 'eth_3491_174' '7' '26' '10.2.58.1/24' '10.2.58.2/24'
# node_174-37100                                
echo "adding host edge node_174-37100"                                
sleep 0.2                                
funCreateV 'eth_174_37100' 'eth_37100_174' '7' '29' '10.2.40.2/24' '10.2.40.1/24'
# node_174-9583                                
echo "adding host edge node_174-9583"                                
sleep 0.2                                
funCreateV 'eth_174_9583' 'eth_9583_174' '7' '85' '10.2.59.1/24' '10.2.59.2/24'
# node_174-7018                                
echo "adding host edge node_174-7018"                                
sleep 0.2                                
funCreateV 'eth_174_7018' 'eth_7018_174' '7' '8' '10.0.109.2/24' '10.0.109.1/24'
# node_174-3257                                
echo "adding host edge node_174-3257"                                
sleep 0.2                                
funCreateV 'eth_174_3257' 'eth_3257_174' '7' '10' '10.0.134.2/24' '10.0.134.1/24'
# node_174-22652                                
echo "adding host edge node_174-22652"                                
sleep 0.2                                
funCreateV 'eth_174_22652' 'eth_22652_174' '7' '75' '10.0.216.2/24' '10.0.216.1/24'
# node_174-6830                                
echo "adding host edge node_174-6830"                                
sleep 0.2                                
funCreateV 'eth_174_6830' 'eth_6830_174' '7' '92' '10.2.60.1/24' '10.2.60.2/24'
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
# node_174-1403                                
echo "adding host edge node_174-1403"                                
sleep 0.2                                
funCreateV 'eth_174_1403' 'eth_1403_174' '7' '78' '10.2.7.2/24' '10.2.7.1/24'
# node_174-6453                                
echo "adding host edge node_174-6453"                                
sleep 0.2                                
funCreateV 'eth_174_6453' 'eth_6453_174' '7' '22' '10.2.62.1/24' '10.2.62.2/24'
# node_174-20764                                
echo "adding host edge node_174-20764"                                
sleep 0.2                                
funCreateV 'eth_174_20764' 'eth_20764_174' '7' '93' '10.2.63.1/24' '10.2.63.2/24'
# node_174-4788                                
echo "adding host edge node_174-4788"                                
sleep 0.2                                
funCreateV 'eth_174_4788' 'eth_4788_174' '7' '63' '10.2.64.1/24' '10.2.64.2/24'
# node_174-38040                                
echo "adding host edge node_174-38040"                                
sleep 0.2                                
funCreateV 'eth_174_38040' 'eth_38040_174' '7' '15' '10.2.65.1/24' '10.2.65.2/24'
# node_174-9318                                
echo "adding host edge node_174-9318"                                
sleep 0.2                                
funCreateV 'eth_174_9318' 'eth_9318_174' '7' '64' '10.2.66.1/24' '10.2.66.2/24'
# node_174-4134                                
echo "adding host edge node_174-4134"                                
sleep 0.2                                
funCreateV 'eth_174_4134' 'eth_4134_174' '7' '33' '10.2.67.1/24' '10.2.67.2/24'
# node_174-1237                                
echo "adding host edge node_174-1237"                                
sleep 0.2                                
funCreateV 'eth_174_1237' 'eth_1237_174' '7' '94' '10.2.68.1/24' '10.2.68.2/24'
# node_174-18106                                
echo "adding host edge node_174-18106"                                
sleep 0.2                                
funCreateV 'eth_174_18106' 'eth_18106_174' '7' '73' '10.0.188.2/24' '10.0.188.1/24'
# node_174-20485                                
echo "adding host edge node_174-20485"                                
sleep 0.2                                
funCreateV 'eth_174_20485' 'eth_20485_174' '7' '95' '10.2.69.1/24' '10.2.69.2/24'
# node_174-2497                                
echo "adding host edge node_174-2497"                                
sleep 0.2                                
funCreateV 'eth_174_2497' 'eth_2497_174' '7' '42' '10.1.155.2/24' '10.1.155.1/24'
# node_174-7497                                
echo "adding host edge node_174-7497"                                
sleep 0.2                                
funCreateV 'eth_174_7497' 'eth_7497_174' '7' '96' '10.2.70.1/24' '10.2.70.2/24'
# node_174-4651                                
echo "adding host edge node_174-4651"                                
sleep 0.2                                
funCreateV 'eth_174_4651' 'eth_4651_174' '7' '61' '10.2.71.1/24' '10.2.71.2/24'
# node_174-9498                                
echo "adding host edge node_174-9498"                                
sleep 0.2                                
funCreateV 'eth_174_9498' 'eth_9498_174' '7' '66' '10.2.72.1/24' '10.2.72.2/24'
# node_174-1273                                
echo "adding host edge node_174-1273"                                
sleep 0.2                                
funCreateV 'eth_174_1273' 'eth_1273_174' '7' '20' '10.2.73.1/24' '10.2.73.2/24'
# node_174-9929                                
echo "adding host edge node_174-9929"                                
sleep 0.2                                
funCreateV 'eth_174_9929' 'eth_9929_174' '7' '97' '10.2.74.1/24' '10.2.74.2/24'
# node_174-6461                                
echo "adding host edge node_174-6461"                                
sleep 0.2                                
funCreateV 'eth_174_6461' 'eth_6461_174' '7' '25' '10.2.75.1/24' '10.2.75.2/24'
# node_174-9680                                
echo "adding host edge node_174-9680"                                
sleep 0.2                                
funCreateV 'eth_174_9680' 'eth_9680_174' '7' '43' '10.2.76.1/24' '10.2.76.2/24'
# node_174-55644                                
echo "adding host edge node_174-55644"                                
sleep 0.2                                
funCreateV 'eth_174_55644' 'eth_55644_174' '7' '45' '10.2.77.1/24' '10.2.77.2/24'
# node_174-16509                                
echo "adding host edge node_174-16509"                                
sleep 0.2                                
funCreateV 'eth_174_16509' 'eth_16509_174' '7' '46' '10.2.78.1/24' '10.2.78.2/24'
# node_174-4837                                
echo "adding host edge node_174-4837"                                
sleep 0.2                                
funCreateV 'eth_174_4837' 'eth_4837_174' '7' '19' '10.2.79.1/24' '10.2.79.2/24'
# node_174-23764                                
echo "adding host edge node_174-23764"                                
sleep 0.2                                
funCreateV 'eth_174_23764' 'eth_23764_174' '7' '59' '10.2.80.1/24' '10.2.80.2/24'
# node_174-6762                                
echo "adding host edge node_174-6762"                                
sleep 0.2                                
funCreateV 'eth_174_6762' 'eth_6762_174' '7' '13' '10.2.81.1/24' '10.2.81.2/24'
# node_174-15412                                
echo "adding host edge node_174-15412"                                
sleep 0.2                                
funCreateV 'eth_174_15412' 'eth_15412_174' '7' '84' '10.2.82.1/24' '10.2.82.2/24'
# node_174-3786                                
echo "adding host edge node_174-3786"                                
sleep 0.2                                
funCreateV 'eth_174_3786' 'eth_3786_174' '7' '30' '10.2.83.1/24' '10.2.83.2/24'
# node_174-58453                                
echo "adding host edge node_174-58453"                                
sleep 0.2                                
funCreateV 'eth_174_58453' 'eth_58453_174' '7' '68' '10.2.84.1/24' '10.2.84.2/24'
# node_7018-2914                                
echo "adding host edge node_7018-2914"                                
sleep 0.2                                
funCreateV 'eth_7018_2914' 'eth_2914_7018' '8' '12' '10.0.103.1/24' '10.0.103.2/24'
# node_7018-2497                                
echo "adding host edge node_7018-2497"                                
sleep 0.2                                
funCreateV 'eth_7018_2497' 'eth_2497_7018' '8' '42' '10.0.104.1/24' '10.0.104.2/24'
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
echo "adding host edge node_7018-6461"                                
sleep 0.2                                
funCreateV 'eth_7018_6461' 'eth_6461_7018' '8' '25' '10.0.110.1/24' '10.0.110.2/24'
# node_7018-3491                                
echo "adding host edge node_7018-3491"                                
sleep 0.2                                
funCreateV 'eth_7018_3491' 'eth_3491_7018' '8' '26' '10.0.111.1/24' '10.0.111.2/24'
# node_7018-4134                                
echo "adding host edge node_7018-4134"                                
sleep 0.2                                
funCreateV 'eth_7018_4134' 'eth_4134_7018' '8' '33' '10.0.112.1/24' '10.0.112.2/24'
# node_7018-701                                
echo "adding host edge node_7018-701"                                
sleep 0.2                                
funCreateV 'eth_7018_701' 'eth_701_7018' '8' '32' '10.0.113.1/24' '10.0.113.2/24'
# node_7018-6939                                
echo "adding host edge node_7018-6939"                                
sleep 0.2                                
funCreateV 'eth_7018_6939' 'eth_6939_7018' '8' '27' '10.0.114.1/24' '10.0.114.2/24'
# node_7018-9680                                
echo "adding host edge node_7018-9680"                                
sleep 0.2                                
funCreateV 'eth_7018_9680' 'eth_9680_7018' '8' '43' '10.0.115.1/24' '10.0.115.2/24'
# node_7018-4775                                
echo "adding host edge node_7018-4775"                                
sleep 0.2                                
funCreateV 'eth_7018_4775' 'eth_4775_7018' '8' '44' '10.0.116.1/24' '10.0.116.2/24'
# node_7018-16509                                
echo "adding host edge node_7018-16509"                                
sleep 0.2                                
funCreateV 'eth_7018_16509' 'eth_16509_7018' '8' '46' '10.0.117.1/24' '10.0.117.2/24'
# node_7018-3257                                
echo "adding host edge node_7018-3257"                                
sleep 0.2                                
funCreateV 'eth_7018_3257' 'eth_3257_7018' '8' '10' '10.0.118.1/24' '10.0.118.2/24'
# node_7018-15169                                
echo "adding host edge node_7018-15169"                                
sleep 0.2                                
funCreateV 'eth_7018_15169' 'eth_15169_7018' '8' '54' '10.0.119.1/24' '10.0.119.2/24'
# node_7018-6762                                
echo "adding host edge node_7018-6762"                                
sleep 0.2                                
funCreateV 'eth_7018_6762' 'eth_6762_7018' '8' '13' '10.0.120.1/24' '10.0.120.2/24'
# node_2519-2497                                
echo "adding host edge node_2519-2497"                                
sleep 0.2                                
funCreateV 'eth_2519_2497' 'eth_2497_2519' '9' '42' '10.1.137.2/24' '10.1.137.1/24'
# node_2519-18106                                
echo "adding host edge node_2519-18106"                                
sleep 0.2                                
funCreateV 'eth_2519_18106' 'eth_18106_2519' '9' '73' '10.0.176.2/24' '10.0.176.1/24'
# node_2519-4637                                
echo "adding host edge node_2519-4637"                                
sleep 0.2                                
funCreateV 'eth_2519_4637' 'eth_4637_2519' '9' '49' '10.2.112.1/24' '10.2.112.2/24'
# node_2519-6939                                
echo "adding host edge node_2519-6939"                                
sleep 0.2                                
funCreateV 'eth_2519_6939' 'eth_6939_2519' '9' '27' '10.1.83.2/24' '10.1.83.1/24'
# node_2519-7670                                
echo "adding host edge node_2519-7670"                                
sleep 0.2                                
funCreateV 'eth_2519_7670' 'eth_7670_2519' '9' '98' '10.2.113.1/24' '10.2.113.2/24'
# node_3257-20912                                
echo "adding host edge node_3257-20912"                                
sleep 0.2                                
funCreateV 'eth_3257_20912' 'eth_20912_3257' '10' '71' '10.0.122.2/24' '10.0.122.1/24'
# node_3257-2914                                
echo "adding host edge node_3257-2914"                                
sleep 0.2                                
funCreateV 'eth_3257_2914' 'eth_2914_3257' '10' '12' '10.0.126.1/24' '10.0.126.2/24'
# node_3257-2497                                
echo "adding host edge node_3257-2497"                                
sleep 0.2                                
funCreateV 'eth_3257_2497' 'eth_2497_3257' '10' '42' '10.0.127.1/24' '10.0.127.2/24'
# node_3257-58453                                
echo "adding host edge node_3257-58453"                                
sleep 0.2                                
funCreateV 'eth_3257_58453' 'eth_58453_3257' '10' '68' '10.0.128.1/24' '10.0.128.2/24'
# node_3257-37100                                
echo "adding host edge node_3257-37100"                                
sleep 0.2                                
funCreateV 'eth_3257_37100' 'eth_37100_3257' '10' '29' '10.0.129.1/24' '10.0.129.2/24'
# node_3257-4837                                
echo "adding host edge node_3257-4837"                                
sleep 0.2                                
funCreateV 'eth_3257_4837' 'eth_4837_3257' '10' '19' '10.0.130.1/24' '10.0.130.2/24'
# node_3257-3491                                
echo "adding host edge node_3257-3491"                                
sleep 0.2                                
funCreateV 'eth_3257_3491' 'eth_3491_3257' '10' '26' '10.0.131.1/24' '10.0.131.2/24'
# node_3257-17676                                
echo "adding host edge node_3257-17676"                                
sleep 0.2                                
funCreateV 'eth_3257_17676' 'eth_17676_3257' '10' '79' '10.0.132.1/24' '10.0.132.2/24'
# node_3257-23352                                
echo "adding host edge node_3257-23352"                                
sleep 0.2                                
funCreateV 'eth_3257_23352' 'eth_23352_3257' '10' '99' '10.0.133.1/24' '10.0.133.2/24'
# node_3257-6453                                
echo "adding host edge node_3257-6453"                                
sleep 0.2                                
funCreateV 'eth_3257_6453' 'eth_6453_3257' '10' '22' '10.0.135.1/24' '10.0.135.2/24'
# node_3257-6461                                
echo "adding host edge node_3257-6461"                                
sleep 0.2                                
funCreateV 'eth_3257_6461' 'eth_6461_3257' '10' '25' '10.0.136.1/24' '10.0.136.2/24'
# node_3257-4134                                
echo "adding host edge node_3257-4134"                                
sleep 0.2                                
funCreateV 'eth_3257_4134' 'eth_4134_3257' '10' '33' '10.0.137.1/24' '10.0.137.2/24'
# node_3257-4766                                
echo "adding host edge node_3257-4766"                                
sleep 0.2                                
funCreateV 'eth_3257_4766' 'eth_4766_3257' '10' '35' '10.0.138.1/24' '10.0.138.2/24'
# node_3257-13237                                
echo "adding cluster edge node_3257-13237"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_13237' 'eth_13237_3257' '10' 'None' '10.0.139.1/24' '10.0.139.2/24'
# node_3257-1239                                
echo "adding host edge node_3257-1239"                                
sleep 0.2                                
funCreateV 'eth_3257_1239' 'eth_1239_3257' '10' '21' '10.0.140.1/24' '10.0.140.2/24'
# node_3257-1273                                
echo "adding host edge node_3257-1273"                                
sleep 0.2                                
funCreateV 'eth_3257_1273' 'eth_1273_3257' '10' '20' '10.0.141.1/24' '10.0.141.2/24'
# node_3257-9498                                
echo "adding host edge node_3257-9498"                                
sleep 0.2                                
funCreateV 'eth_3257_9498' 'eth_9498_3257' '10' '66' '10.0.142.1/24' '10.0.142.2/24'
# node_3257-22652                                
echo "adding host edge node_3257-22652"                                
sleep 0.2                                
funCreateV 'eth_3257_22652' 'eth_22652_3257' '10' '75' '10.0.143.1/24' '10.0.143.2/24'
# node_3257-16509                                
echo "adding host edge node_3257-16509"                                
sleep 0.2                                
funCreateV 'eth_3257_16509' 'eth_16509_3257' '10' '46' '10.0.144.1/24' '10.0.144.2/24'
# node_3257-23764                                
echo "adding host edge node_3257-23764"                                
sleep 0.2                                
funCreateV 'eth_3257_23764' 'eth_23764_3257' '10' '59' '10.0.145.1/24' '10.0.145.2/24'
# node_3257-137753                                
echo "adding cluster edge node_3257-137753"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_137753' 'eth_137753_3257' '10' 'None' '10.0.146.1/24' '10.0.146.2/24'
# node_3257-6830                                
echo "adding host edge node_3257-6830"                                
sleep 0.2                                
funCreateV 'eth_3257_6830' 'eth_6830_3257' '10' '92' '10.0.147.1/24' '10.0.147.2/24'
# node_3257-57304                                
echo "adding cluster edge node_3257-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_3257_57304' 'eth_57304_3257' '10' 'None' '10.0.148.1/24' '10.0.148.2/24'
# node_3257-4637                                
echo "adding host edge node_3257-4637"                                
sleep 0.2                                
funCreateV 'eth_3257_4637' 'eth_4637_3257' '10' '49' '10.0.150.1/24' '10.0.150.2/24'
# node_3257-4826                                
echo "adding host edge node_3257-4826"                                
sleep 0.2                                
funCreateV 'eth_3257_4826' 'eth_4826_3257' '10' '91' '10.0.151.1/24' '10.0.151.2/24'
# node_3257-5511                                
echo "adding host edge node_3257-5511"                                
sleep 0.2                                
funCreateV 'eth_3257_5511' 'eth_5511_3257' '10' '17' '10.0.152.1/24' '10.0.152.2/24'
# node_3257-15169                                
echo "adding host edge node_3257-15169"                                
sleep 0.2                                
funCreateV 'eth_3257_15169' 'eth_15169_3257' '10' '54' '10.0.153.1/24' '10.0.153.2/24'
# node_3257-6762                                
echo "adding host edge node_3257-6762"                                
sleep 0.2                                
funCreateV 'eth_3257_6762' 'eth_6762_3257' '10' '13' '10.0.154.1/24' '10.0.154.2/24'
# node_3741-6939                                
echo "adding host edge node_3741-6939"                                
sleep 0.2                                
funCreateV 'eth_3741_6939' 'eth_6939_3741' '11' '27' '10.0.160.1/24' '10.0.160.2/24'
# node_3741-15412                                
echo "adding host edge node_3741-15412"                                
sleep 0.2                                
funCreateV 'eth_3741_15412' 'eth_15412_3741' '11' '84' '10.0.161.1/24' '10.0.161.2/24'
# node_3741-4651                                
echo "adding host edge node_3741-4651"                                
sleep 0.2                                
funCreateV 'eth_3741_4651' 'eth_4651_3741' '11' '61' '10.0.162.1/24' '10.0.162.2/24'
# node_3741-9002                                
echo "adding host edge node_3741-9002"                                
sleep 0.2                                
funCreateV 'eth_3741_9002' 'eth_9002_3741' '11' '28' '10.0.164.1/24' '10.0.164.2/24'
# node_3741-4134                                
echo "adding host edge node_3741-4134"                                
sleep 0.2                                
funCreateV 'eth_3741_4134' 'eth_4134_3741' '11' '33' '10.0.165.1/24' '10.0.165.2/24'
# node_3741-2914                                
echo "adding host edge node_3741-2914"                                
sleep 0.2                                
funCreateV 'eth_3741_2914' 'eth_2914_3741' '11' '12' '10.0.166.1/24' '10.0.166.2/24'
# node_3741-6461                                
echo "adding host edge node_3741-6461"                                
sleep 0.2                                
funCreateV 'eth_3741_6461' 'eth_6461_3741' '11' '25' '10.0.167.1/24' '10.0.167.2/24'
# node_3741-64049                                
echo "adding host edge node_3741-64049"                                
sleep 0.2                                
funCreateV 'eth_3741_64049' 'eth_64049_3741' '11' '24' '10.0.168.1/24' '10.0.168.2/24'
# node_3741-4788                                
echo "adding host edge node_3741-4788"                                
sleep 0.2                                
funCreateV 'eth_3741_4788' 'eth_4788_3741' '11' '63' '10.0.169.1/24' '10.0.169.2/24'
# node_3741-9318                                
echo "adding host edge node_3741-9318"                                
sleep 0.2                                
funCreateV 'eth_3741_9318' 'eth_9318_3741' '11' '64' '10.0.170.1/24' '10.0.170.2/24'
# node_3741-13237                                
echo "adding cluster edge node_3741-13237"                                
sleep 0.2                                
funCreateClusterV 'eth_3741_13237' 'eth_13237_3741' '11' 'None' '10.0.171.1/24' '10.0.171.2/24'
# node_3741-3462                                
echo "adding host edge node_3741-3462"                                
sleep 0.2                                
funCreateV 'eth_3741_3462' 'eth_3462_3741' '11' '67' '10.0.172.1/24' '10.0.172.2/24'
# node_3741-23764                                
echo "adding host edge node_3741-23764"                                
sleep 0.2                                
funCreateV 'eth_3741_23764' 'eth_23764_3741' '11' '59' '10.0.173.1/24' '10.0.173.2/24'
# node_3741-15169                                
echo "adding host edge node_3741-15169"                                
sleep 0.2                                
funCreateV 'eth_3741_15169' 'eth_15169_3741' '11' '54' '10.0.174.1/24' '10.0.174.2/24'
# node_2914-6453                                
echo "adding host edge node_2914-6453"                                
sleep 0.2                                
funCreateV 'eth_2914_6453' 'eth_6453_2914' '12' '22' '10.1.194.1/24' '10.1.194.2/24'
# node_2914-293                                
echo "adding host edge node_2914-293"                                
sleep 0.2                                
funCreateV 'eth_2914_293' 'eth_293_2914' '12' '18' '10.1.171.2/24' '10.1.171.1/24'
# node_2914-9304                                
echo "adding host edge node_2914-9304"                                
sleep 0.2                                
funCreateV 'eth_2914_9304' 'eth_9304_2914' '12' '60' '10.1.195.1/24' '10.1.195.2/24'
# node_2914-6461                                
echo "adding host edge node_2914-6461"                                
sleep 0.2                                
funCreateV 'eth_2914_6461' 'eth_6461_2914' '12' '25' '10.1.196.1/24' '10.1.196.2/24'
# node_2914-57866                                
echo "adding host edge node_2914-57866"                                
sleep 0.2                                
funCreateV 'eth_2914_57866' 'eth_57866_2914' '12' '37' '10.0.221.2/24' '10.0.221.1/24'
# node_2914-4637                                
echo "adding host edge node_2914-4637"                                
sleep 0.2                                
funCreateV 'eth_2914_4637' 'eth_4637_2914' '12' '49' '10.1.197.1/24' '10.1.197.2/24'
# node_2914-38040                                
echo "adding host edge node_2914-38040"                                
sleep 0.2                                
funCreateV 'eth_2914_38040' 'eth_38040_2914' '12' '15' '10.1.198.1/24' '10.1.198.2/24'
# node_2914-4651                                
echo "adding host edge node_2914-4651"                                
sleep 0.2                                
funCreateV 'eth_2914_4651' 'eth_4651_2914' '12' '61' '10.1.199.1/24' '10.1.199.2/24'
# node_2914-4837                                
echo "adding host edge node_2914-4837"                                
sleep 0.2                                
funCreateV 'eth_2914_4837' 'eth_4837_2914' '12' '19' '10.1.200.1/24' '10.1.200.2/24'
# node_2914-21859                                
echo "adding cluster edge node_2914-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_21859' 'eth_21859_2914' '12' 'None' '10.1.201.1/24' '10.1.201.2/24'
# node_2914-17676                                
echo "adding host edge node_2914-17676"                                
sleep 0.2                                
funCreateV 'eth_2914_17676' 'eth_17676_2914' '12' '79' '10.1.202.1/24' '10.1.202.2/24'
# node_2914-23764                                
echo "adding host edge node_2914-23764"                                
sleep 0.2                                
funCreateV 'eth_2914_23764' 'eth_23764_2914' '12' '59' '10.1.203.1/24' '10.1.203.2/24'
# node_2914-9583                                
echo "adding host edge node_2914-9583"                                
sleep 0.2                                
funCreateV 'eth_2914_9583' 'eth_9583_2914' '12' '85' '10.1.204.1/24' '10.1.204.2/24'
# node_2914-1239                                
echo "adding host edge node_2914-1239"                                
sleep 0.2                                
funCreateV 'eth_2914_1239' 'eth_1239_2914' '12' '21' '10.1.205.1/24' '10.1.205.2/24'
# node_2914-37100                                
echo "adding host edge node_2914-37100"                                
sleep 0.2                                
funCreateV 'eth_2914_37100' 'eth_37100_2914' '12' '29' '10.1.206.1/24' '10.1.206.2/24'
# node_2914-3491                                
echo "adding host edge node_2914-3491"                                
sleep 0.2                                
funCreateV 'eth_2914_3491' 'eth_3491_2914' '12' '26' '10.1.207.1/24' '10.1.207.2/24'
# node_2914-18106                                
echo "adding host edge node_2914-18106"                                
sleep 0.2                                
funCreateV 'eth_2914_18106' 'eth_18106_2914' '12' '73' '10.0.183.2/24' '10.0.183.1/24'
# node_2914-2497                                
echo "adding host edge node_2914-2497"                                
sleep 0.2                                
funCreateV 'eth_2914_2497' 'eth_2497_2914' '12' '42' '10.1.140.2/24' '10.1.140.1/24'
# node_2914-64049                                
echo "adding host edge node_2914-64049"                                
sleep 0.2                                
funCreateV 'eth_2914_64049' 'eth_64049_2914' '12' '24' '10.1.209.1/24' '10.1.209.2/24'
# node_2914-7473                                
echo "adding host edge node_2914-7473"                                
sleep 0.2                                
funCreateV 'eth_2914_7473' 'eth_7473_2914' '12' '80' '10.1.210.1/24' '10.1.210.2/24'
# node_2914-4788                                
echo "adding host edge node_2914-4788"                                
sleep 0.2                                
funCreateV 'eth_2914_4788' 'eth_4788_2914' '12' '63' '10.1.211.1/24' '10.1.211.2/24'
# node_2914-3786                                
echo "adding host edge node_2914-3786"                                
sleep 0.2                                
funCreateV 'eth_2914_3786' 'eth_3786_2914' '12' '30' '10.1.212.1/24' '10.1.212.2/24'
# node_2914-23352                                
echo "adding host edge node_2914-23352"                                
sleep 0.2                                
funCreateV 'eth_2914_23352' 'eth_23352_2914' '12' '99' '10.1.213.1/24' '10.1.213.2/24'
# node_2914-9318                                
echo "adding host edge node_2914-9318"                                
sleep 0.2                                
funCreateV 'eth_2914_9318' 'eth_9318_2914' '12' '64' '10.1.214.1/24' '10.1.214.2/24'
# node_2914-4134                                
echo "adding host edge node_2914-4134"                                
sleep 0.2                                
funCreateV 'eth_2914_4134' 'eth_4134_2914' '12' '33' '10.1.215.1/24' '10.1.215.2/24'
# node_2914-132203                                
echo "adding host edge node_2914-132203"                                
sleep 0.2                                
funCreateV 'eth_2914_132203' 'eth_132203_2914' '12' '34' '10.1.216.1/24' '10.1.216.2/24'
# node_2914-4766                                
echo "adding host edge node_2914-4766"                                
sleep 0.2                                
funCreateV 'eth_2914_4766' 'eth_4766_2914' '12' '35' '10.1.217.1/24' '10.1.217.2/24'
# node_2914-22548                                
echo "adding cluster edge node_2914-22548"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_22548' 'eth_22548_2914' '12' 'None' '10.1.218.1/24' '10.1.218.2/24'
# node_2914-5539                                
echo "adding cluster edge node_2914-5539"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_5539' 'eth_5539_2914' '12' 'None' '10.1.219.1/24' '10.1.219.2/24'
# node_2914-6762                                
echo "adding host edge node_2914-6762"                                
sleep 0.2                                
funCreateV 'eth_2914_6762' 'eth_6762_2914' '12' '13' '10.1.220.1/24' '10.1.220.2/24'
# node_2914-58453                                
echo "adding host edge node_2914-58453"                                
sleep 0.2                                
funCreateV 'eth_2914_58453' 'eth_58453_2914' '12' '68' '10.1.221.1/24' '10.1.221.2/24'
# node_2914-38634                                
echo "adding cluster edge node_2914-38634"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_38634' 'eth_38634_2914' '12' 'None' '10.1.222.1/24' '10.1.222.2/24'
# node_2914-9498                                
echo "adding host edge node_2914-9498"                                
sleep 0.2                                
funCreateV 'eth_2914_9498' 'eth_9498_2914' '12' '66' '10.1.223.1/24' '10.1.223.2/24'
# node_2914-1273                                
echo "adding host edge node_2914-1273"                                
sleep 0.2                                
funCreateV 'eth_2914_1273' 'eth_1273_2914' '12' '20' '10.1.224.1/24' '10.1.224.2/24'
# node_2914-9929                                
echo "adding host edge node_2914-9929"                                
sleep 0.2                                
funCreateV 'eth_2914_9929' 'eth_9929_2914' '12' '97' '10.1.225.1/24' '10.1.225.2/24'
# node_2914-64050                                
echo "adding host edge node_2914-64050"                                
sleep 0.2                                
funCreateV 'eth_2914_64050' 'eth_64050_2914' '12' '87' '10.1.226.1/24' '10.1.226.2/24'
# node_2914-2514                                
echo "adding cluster edge node_2914-2514"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_2514' 'eth_2514_2914' '12' 'None' '10.1.227.1/24' '10.1.227.2/24'
# node_2914-3462                                
echo "adding host edge node_2914-3462"                                
sleep 0.2                                
funCreateV 'eth_2914_3462' 'eth_3462_2914' '12' '67' '10.1.228.1/24' '10.1.228.2/24'
# node_2914-4775                                
echo "adding host edge node_2914-4775"                                
sleep 0.2                                
funCreateV 'eth_2914_4775' 'eth_4775_2914' '12' '44' '10.1.229.1/24' '10.1.229.2/24'
# node_2914-16509                                
echo "adding host edge node_2914-16509"                                
sleep 0.2                                
funCreateV 'eth_2914_16509' 'eth_16509_2914' '12' '46' '10.1.230.1/24' '10.1.230.2/24'
# node_2914-10089                                
echo "adding host edge node_2914-10089"                                
sleep 0.2                                
funCreateV 'eth_2914_10089' 'eth_10089_2914' '12' '88' '10.1.231.1/24' '10.1.231.2/24'
# node_2914-15932                                
echo "adding host edge node_2914-15932"                                
sleep 0.2                                
funCreateV 'eth_2914_15932' 'eth_15932_2914' '12' '89' '10.1.232.1/24' '10.1.232.2/24'
# node_2914-4538                                
echo "adding host edge node_2914-4538"                                
sleep 0.2                                
funCreateV 'eth_2914_4538' 'eth_4538_2914' '12' '90' '10.1.233.1/24' '10.1.233.2/24'
# node_2914-18403                                
echo "adding host edge node_2914-18403"                                
sleep 0.2                                
funCreateV 'eth_2914_18403' 'eth_18403_2914' '12' '47' '10.1.234.1/24' '10.1.234.2/24'
# node_2914-9605                                
echo "adding host edge node_2914-9605"                                
sleep 0.2                                
funCreateV 'eth_2914_9605' 'eth_9605_2914' '12' '69' '10.1.235.1/24' '10.1.235.2/24'
# node_2914-4809                                
echo "adding host edge node_2914-4809"                                
sleep 0.2                                
funCreateV 'eth_2914_4809' 'eth_4809_2914' '12' '48' '10.1.236.1/24' '10.1.236.2/24'
# node_2914-5413                                
echo "adding host edge node_2914-5413"                                
sleep 0.2                                
funCreateV 'eth_2914_5413' 'eth_5413_2914' '12' '31' '10.1.192.2/24' '10.1.192.1/24'
# node_2914-6663                                
echo "adding host edge node_2914-6663"                                
sleep 0.2                                
funCreateV 'eth_2914_6663' 'eth_6663_2914' '12' '52' '10.1.237.1/24' '10.1.237.2/24'
# node_2914-5511                                
echo "adding host edge node_2914-5511"                                
sleep 0.2                                
funCreateV 'eth_2914_5511' 'eth_5511_2914' '12' '17' '10.1.238.1/24' '10.1.238.2/24'
# node_2914-15169                                
echo "adding host edge node_2914-15169"                                
sleep 0.2                                
funCreateV 'eth_2914_15169' 'eth_15169_2914' '12' '54' '10.1.239.1/24' '10.1.239.2/24'
# node_2914-24157                                
echo "adding cluster edge node_2914-24157"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_24157' 'eth_24157_2914' '12' 'None' '10.1.240.1/24' '10.1.240.2/24'
# node_2914-9924                                
echo "adding cluster edge node_2914-9924"                                
sleep 0.2                                
funCreateClusterV 'eth_2914_9924' 'eth_9924_2914' '12' 'None' '10.1.241.1/24' '10.1.241.2/24'
# node_2914-15412                                
echo "adding host edge node_2914-15412"                                
sleep 0.2                                
funCreateV 'eth_2914_15412' 'eth_15412_2914' '12' '84' '10.1.242.1/24' '10.1.242.2/24'
# node_2914-9957                                
echo "adding host edge node_2914-9957"                                
sleep 0.2                                
funCreateV 'eth_2914_9957' 'eth_9957_2914' '12' '56' '10.1.243.1/24' '10.1.243.2/24'
# node_2914-45974                                
echo "adding host edge node_2914-45974"                                
sleep 0.2                                
funCreateV 'eth_2914_45974' 'eth_45974_2914' '12' '58' '10.1.244.1/24' '10.1.244.2/24'
# node_6762-9304                                
echo "adding host edge node_6762-9304"                                
sleep 0.2                                
funCreateV 'eth_6762_9304' 'eth_9304_6762' '13' '60' '10.2.163.2/24' '10.2.163.1/24'
# node_6762-37100                                
echo "adding host edge node_6762-37100"                                
sleep 0.2                                
funCreateV 'eth_6762_37100' 'eth_37100_6762' '13' '29' '10.2.41.2/24' '10.2.41.1/24'
# node_6762-49367                                
echo "adding cluster edge node_6762-49367"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_49367' 'eth_49367_6762' '13' 'None' '10.2.169.1/24' '10.2.169.2/24'
# node_6762-6453                                
echo "adding host edge node_6762-6453"                                
sleep 0.2                                
funCreateV 'eth_6762_6453' 'eth_6453_6762' '13' '22' '10.2.95.2/24' '10.2.95.1/24'
# node_6762-38040                                
echo "adding host edge node_6762-38040"                                
sleep 0.2                                
funCreateV 'eth_6762_38040' 'eth_38040_6762' '13' '15' '10.2.170.1/24' '10.2.170.2/24'
# node_6762-9680                                
echo "adding host edge node_6762-9680"                                
sleep 0.2                                
funCreateV 'eth_6762_9680' 'eth_9680_6762' '13' '43' '10.2.171.1/24' '10.2.171.2/24'
# node_6762-3216                                
echo "adding cluster edge node_6762-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_6762_3216' 'eth_3216_6762' '13' 'None' '10.2.172.1/24' '10.2.172.2/24'
# node_6762-1273                                
echo "adding host edge node_6762-1273"                                
sleep 0.2                                
funCreateV 'eth_6762_1273' 'eth_1273_6762' '13' '20' '10.2.173.1/24' '10.2.173.2/24'
# node_6762-3491                                
echo "adding host edge node_6762-3491"                                
sleep 0.2                                
funCreateV 'eth_6762_3491' 'eth_3491_6762' '13' '26' '10.2.174.1/24' '10.2.174.2/24'
# node_6762-4134                                
echo "adding host edge node_6762-4134"                                
sleep 0.2                                
funCreateV 'eth_6762_4134' 'eth_4134_6762' '13' '33' '10.2.175.1/24' '10.2.175.2/24'
# node_6762-6939                                
echo "adding host edge node_6762-6939"                                
sleep 0.2                                
funCreateV 'eth_6762_6939' 'eth_6939_6762' '13' '27' '10.1.131.2/24' '10.1.131.1/24'
# node_6762-7303                                
echo "adding host edge node_6762-7303"                                
sleep 0.2                                
funCreateV 'eth_6762_7303' 'eth_7303_6762' '13' '51' '10.2.176.1/24' '10.2.176.2/24'
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
# node_2516-7670                                
echo "adding host edge node_2516-7670"                                
sleep 0.2                                
funCreateV 'eth_2516_7670' 'eth_7670_2516' '14' '98' '10.2.202.2/24' '10.2.202.1/24'
# node_2516-38634                                
echo "adding cluster edge node_2516-38634"                                
sleep 0.2                                
funCreateClusterV 'eth_2516_38634' 'eth_38634_2516' '14' 'None' '10.2.212.1/24' '10.2.212.2/24'
# node_38040-6939                                
echo "adding host edge node_38040-6939"                                
sleep 0.2                                
funCreateV 'eth_38040_6939' 'eth_6939_38040' '15' '27' '10.1.86.2/24' '10.1.86.1/24'
# node_38040-23969                                
echo "adding cluster edge node_38040-23969"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_23969' 'eth_23969_38040' '15' 'None' '10.2.213.2/24' '10.2.213.1/24'
# node_38040-6453                                
echo "adding host edge node_38040-6453"                                
sleep 0.2                                
funCreateV 'eth_38040_6453' 'eth_6453_38040' '15' '22' '10.2.85.2/24' '10.2.85.1/24'
# node_38040-58453                                
echo "adding host edge node_38040-58453"                                
sleep 0.2                                
funCreateV 'eth_38040_58453' 'eth_58453_38040' '15' '68' '10.2.217.1/24' '10.2.217.2/24'
# node_38040-18106                                
echo "adding host edge node_38040-18106"                                
sleep 0.2                                
funCreateV 'eth_38040_18106' 'eth_18106_38040' '15' '73' '10.0.178.2/24' '10.0.178.1/24'
# node_38040-7473                                
echo "adding host edge node_38040-7473"                                
sleep 0.2                                
funCreateV 'eth_38040_7473' 'eth_7473_38040' '15' '80' '10.2.218.1/24' '10.2.218.2/24'
# node_38040-8492                                
echo "adding host edge node_38040-8492"                                
sleep 0.2                                
funCreateV 'eth_38040_8492' 'eth_8492_38040' '15' '76' '10.0.230.2/24' '10.0.230.1/24'
# node_38040-2497                                
echo "adding host edge node_38040-2497"                                
sleep 0.2                                
funCreateV 'eth_38040_2497' 'eth_2497_38040' '15' '42' '10.1.145.2/24' '10.1.145.1/24'
# node_38040-9002                                
echo "adding host edge node_38040-9002"                                
sleep 0.2                                
funCreateV 'eth_38040_9002' 'eth_9002_38040' '15' '28' '10.2.219.1/24' '10.2.219.2/24'
# node_38040-3491                                
echo "adding host edge node_38040-3491"                                
sleep 0.2                                
funCreateV 'eth_38040_3491' 'eth_3491_38040' '15' '26' '10.2.220.1/24' '10.2.220.2/24'
# node_38040-12552                                
echo "adding host edge node_38040-12552"                                
sleep 0.2                                
funCreateV 'eth_38040_12552' 'eth_12552_38040' '15' '36' '10.2.132.2/24' '10.2.132.1/24'
# node_38040-20764                                
echo "adding host edge node_38040-20764"                                
sleep 0.2                                
funCreateV 'eth_38040_20764' 'eth_20764_38040' '15' '93' '10.2.221.1/24' '10.2.221.2/24'
# node_38040-293                                
echo "adding host edge node_38040-293"                                
sleep 0.2                                
funCreateV 'eth_38040_293' 'eth_293_38040' '15' '18' '10.1.182.2/24' '10.1.182.1/24'
# node_38040-131293                                
echo "adding cluster edge node_38040-131293"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_131293' 'eth_131293_38040' '15' 'None' '10.2.222.1/24' '10.2.222.2/24'
# node_38040-134166                                
echo "adding cluster edge node_38040-134166"                                
sleep 0.2                                
funCreateClusterV 'eth_38040_134166' 'eth_134166_38040' '15' 'None' '10.2.223.1/24' '10.2.223.2/24'
# node_2152-6939                                
echo "adding host edge node_2152-6939"                                
sleep 0.2                                
funCreateV 'eth_2152_6939' 'eth_6939_2152' '16' '27' '10.1.58.1/24' '10.1.58.2/24'
# node_2152-11164                                
echo "adding cluster edge node_2152-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_11164' 'eth_11164_2152' '16' 'None' '10.1.59.1/24' '10.1.59.2/24'
# node_2152-1239                                
echo "adding host edge node_2152-1239"                                
sleep 0.2                                
funCreateV 'eth_2152_1239' 'eth_1239_2152' '16' '21' '10.1.60.1/24' '10.1.60.2/24'
# node_2152-6461                                
echo "adding host edge node_2152-6461"                                
sleep 0.2                                
funCreateV 'eth_2152_6461' 'eth_6461_2152' '16' '25' '10.1.62.1/24' '10.1.62.2/24'
# node_2152-2153                                
echo "adding cluster edge node_2152-2153"                                
sleep 0.2                                
funCreateClusterV 'eth_2152_2153' 'eth_2153_2152' '16' 'None' '10.1.63.1/24' '10.1.63.2/24'
# node_2152-3786                                
echo "adding host edge node_2152-3786"                                
sleep 0.2                                
funCreateV 'eth_2152_3786' 'eth_3786_2152' '16' '30' '10.1.64.1/24' '10.1.64.2/24'
# node_2152-9318                                
echo "adding host edge node_2152-9318"                                
sleep 0.2                                
funCreateV 'eth_2152_9318' 'eth_9318_2152' '16' '64' '10.1.65.1/24' '10.1.65.2/24'
# node_2152-132203                                
echo "adding host edge node_2152-132203"                                
sleep 0.2                                
funCreateV 'eth_2152_132203' 'eth_132203_2152' '16' '34' '10.1.66.1/24' '10.1.66.2/24'
# node_2152-4766                                
echo "adding host edge node_2152-4766"                                
sleep 0.2                                
funCreateV 'eth_2152_4766' 'eth_4766_2152' '16' '35' '10.1.67.1/24' '10.1.67.2/24'
# node_2152-9680                                
echo "adding host edge node_2152-9680"                                
sleep 0.2                                
funCreateV 'eth_2152_9680' 'eth_9680_2152' '16' '43' '10.1.68.1/24' '10.1.68.2/24'
# node_2152-16509                                
echo "adding host edge node_2152-16509"                                
sleep 0.2                                
funCreateV 'eth_2152_16509' 'eth_16509_2152' '16' '46' '10.1.69.1/24' '10.1.69.2/24'
# node_2152-15169                                
echo "adding host edge node_2152-15169"                                
sleep 0.2                                
funCreateV 'eth_2152_15169' 'eth_15169_2152' '16' '54' '10.1.70.1/24' '10.1.70.2/24'
# node_2152-9505                                
echo "adding host edge node_2152-9505"                                
sleep 0.2                                
funCreateV 'eth_2152_9505' 'eth_9505_2152' '16' '55' '10.1.71.1/24' '10.1.71.2/24'
# node_2152-15412                                
echo "adding host edge node_2152-15412"                                
sleep 0.2                                
funCreateV 'eth_2152_15412' 'eth_15412_2152' '16' '84' '10.1.72.1/24' '10.1.72.2/24'
# node_5511-4837                                
echo "adding host edge node_5511-4837"                                
sleep 0.2                                
funCreateV 'eth_5511_4837' 'eth_4837_5511' '17' '19' '10.3.8.2/24' '10.3.8.1/24'
# node_5511-4657                                
echo "adding host edge node_5511-4657"                                
sleep 0.2                                
funCreateV 'eth_5511_4657' 'eth_4657_5511' '17' '57' '10.3.18.1/24' '10.3.18.2/24'
# node_5511-6939                                
echo "adding host edge node_5511-6939"                                
sleep 0.2                                
funCreateV 'eth_5511_6939' 'eth_6939_5511' '17' '27' '10.1.88.2/24' '10.1.88.1/24'
# node_5511-1239                                
echo "adding host edge node_5511-1239"                                
sleep 0.2                                
funCreateV 'eth_5511_1239' 'eth_1239_5511' '17' '21' '10.2.16.2/24' '10.2.16.1/24'
# node_5511-12975                                
echo "adding cluster edge node_5511-12975"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_12975' 'eth_12975_5511' '17' 'None' '10.3.19.1/24' '10.3.19.2/24'
# node_5511-3320                                
echo "adding host edge node_5511-3320"                                
sleep 0.2                                
funCreateV 'eth_5511_3320' 'eth_3320_5511' '17' '81' '10.3.20.1/24' '10.3.20.2/24'
# node_5511-6461                                
echo "adding host edge node_5511-6461"                                
sleep 0.2                                
funCreateV 'eth_5511_6461' 'eth_6461_5511' '17' '25' '10.2.195.2/24' '10.2.195.1/24'
# node_5511-6830                                
echo "adding host edge node_5511-6830"                                
sleep 0.2                                
funCreateV 'eth_5511_6830' 'eth_6830_5511' '17' '92' '10.2.211.2/24' '10.2.211.1/24'
# node_5511-57304                                
echo "adding cluster edge node_5511-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_5511_57304' 'eth_57304_5511' '17' 'None' '10.3.21.1/24' '10.3.21.2/24'
# node_5511-2497                                
echo "adding host edge node_5511-2497"                                
sleep 0.2                                
funCreateV 'eth_5511_2497' 'eth_2497_5511' '17' '42' '10.1.169.2/24' '10.1.169.1/24'
# node_5511-6453                                
echo "adding host edge node_5511-6453"                                
sleep 0.2                                
funCreateV 'eth_5511_6453' 'eth_6453_5511' '17' '22' '10.2.109.2/24' '10.2.109.1/24'
# node_5511-12479                                
echo "adding host edge node_5511-12479"                                
sleep 0.2                                
funCreateV 'eth_5511_12479' 'eth_12479_5511' '17' '53' '10.3.22.1/24' '10.3.22.2/24'
# node_293-6939                                
echo "adding host edge node_293-6939"                                
sleep 0.2                                
funCreateV 'eth_293_6939' 'eth_6939_293' '18' '27' '10.1.81.2/24' '10.1.81.1/24'
# node_293-2497                                
echo "adding host edge node_293-2497"                                
sleep 0.2                                
funCreateV 'eth_293_2497' 'eth_2497_293' '18' '42' '10.1.144.2/24' '10.1.144.1/24'
# node_293-6453                                
echo "adding host edge node_293-6453"                                
sleep 0.2                                
funCreateV 'eth_293_6453' 'eth_6453_293' '18' '22' '10.1.172.1/24' '10.1.172.2/24'
# node_293-3491                                
echo "adding host edge node_293-3491"                                
sleep 0.2                                
funCreateV 'eth_293_3491' 'eth_3491_293' '18' '26' '10.1.173.1/24' '10.1.173.2/24'
# node_293-4788                                
echo "adding host edge node_293-4788"                                
sleep 0.2                                
funCreateV 'eth_293_4788' 'eth_4788_293' '18' '63' '10.1.174.1/24' '10.1.174.2/24'
# node_293-1273                                
echo "adding host edge node_293-1273"                                
sleep 0.2                                
funCreateV 'eth_293_1273' 'eth_1273_293' '18' '20' '10.1.175.1/24' '10.1.175.2/24'
# node_293-22388                                
echo "adding cluster edge node_293-22388"                                
sleep 0.2                                
funCreateClusterV 'eth_293_22388' 'eth_22388_293' '18' 'None' '10.1.176.1/24' '10.1.176.2/24'
# node_293-9002                                
echo "adding host edge node_293-9002"                                
sleep 0.2                                
funCreateV 'eth_293_9002' 'eth_9002_293' '18' '28' '10.1.177.1/24' '10.1.177.2/24'
# node_293-64050                                
echo "adding host edge node_293-64050"                                
sleep 0.2                                
funCreateV 'eth_293_64050' 'eth_64050_293' '18' '87' '10.1.178.1/24' '10.1.178.2/24'
# node_293-23911                                
echo "adding cluster edge node_293-23911"                                
sleep 0.2                                
funCreateClusterV 'eth_293_23911' 'eth_23911_293' '18' 'None' '10.1.179.1/24' '10.1.179.2/24'
# node_293-9605                                
echo "adding host edge node_293-9605"                                
sleep 0.2                                
funCreateV 'eth_293_9605' 'eth_9605_293' '18' '69' '10.1.180.1/24' '10.1.180.2/24'
# node_293-15169                                
echo "adding host edge node_293-15169"                                
sleep 0.2                                
funCreateV 'eth_293_15169' 'eth_15169_293' '18' '54' '10.1.181.1/24' '10.1.181.2/24'
# node_4837-138421                                
echo "adding cluster edge node_4837-138421"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_138421' 'eth_138421_4837' '19' 'None' '10.3.6.2/24' '10.3.6.1/24'
# node_4837-6461                                
echo "adding host edge node_4837-6461"                                
sleep 0.2                                
funCreateV 'eth_4837_6461' 'eth_6461_4837' '19' '25' '10.2.183.2/24' '10.2.183.1/24'
# node_4837-6453                                
echo "adding host edge node_4837-6453"                                
sleep 0.2                                
funCreateV 'eth_4837_6453' 'eth_6453_4837' '19' '22' '10.2.86.2/24' '10.2.86.1/24'
# node_4837-6830                                
echo "adding host edge node_4837-6830"                                
sleep 0.2                                
funCreateV 'eth_4837_6830' 'eth_6830_4837' '19' '92' '10.2.203.2/24' '10.2.203.1/24'
# node_4837-20485                                
echo "adding host edge node_4837-20485"                                
sleep 0.2                                
funCreateV 'eth_4837_20485' 'eth_20485_4837' '19' '95' '10.3.9.1/24' '10.3.9.2/24'
# node_4837-2497                                
echo "adding host edge node_4837-2497"                                
sleep 0.2                                
funCreateV 'eth_4837_2497' 'eth_2497_4837' '19' '42' '10.1.146.2/24' '10.1.146.1/24'
# node_4837-4808                                
echo "adding cluster edge node_4837-4808"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_4808' 'eth_4808_4837' '19' 'None' '10.3.10.1/24' '10.3.10.2/24'
# node_4837-702                                
echo "adding host edge node_4837-702"                                
sleep 0.2                                
funCreateV 'eth_4837_702' 'eth_702_4837' '19' '62' '10.3.11.1/24' '10.3.11.2/24'
# node_4837-6939                                
echo "adding host edge node_4837-6939"                                
sleep 0.2                                
funCreateV 'eth_4837_6939' 'eth_6939_4837' '19' '27' '10.1.108.2/24' '10.1.108.1/24'
# node_4837-4134                                
echo "adding host edge node_4837-4134"                                
sleep 0.2                                
funCreateV 'eth_4837_4134' 'eth_4134_4837' '19' '33' '10.3.12.1/24' '10.3.12.2/24'
# node_4837-139007                                
echo "adding cluster edge node_4837-139007"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_139007' 'eth_139007_4837' '19' 'None' '10.3.13.1/24' '10.3.13.2/24'
# node_4837-701                                
echo "adding host edge node_4837-701"                                
sleep 0.2                                
funCreateV 'eth_4837_701' 'eth_701_4837' '19' '32' '10.3.14.1/24' '10.3.14.2/24'
# node_4837-9929                                
echo "adding host edge node_4837-9929"                                
sleep 0.2                                
funCreateV 'eth_4837_9929' 'eth_9929_4837' '19' '97' '10.3.15.1/24' '10.3.15.2/24'
# node_4837-4538                                
echo "adding host edge node_4837-4538"                                
sleep 0.2                                
funCreateV 'eth_4837_4538' 'eth_4538_4837' '19' '90' '10.3.16.1/24' '10.3.16.2/24'
# node_4837-1239                                
echo "adding host edge node_4837-1239"                                
sleep 0.2                                
funCreateV 'eth_4837_1239' 'eth_1239_4837' '19' '21' '10.2.25.2/24' '10.2.25.1/24'
# node_4837-9808                                
echo "adding cluster edge node_4837-9808"                                
sleep 0.2                                
funCreateClusterV 'eth_4837_9808' 'eth_9808_4837' '19' 'None' '10.3.17.1/24' '10.3.17.2/24'
# node_1273-4651                                
echo "adding host edge node_1273-4651"                                
sleep 0.2                                
funCreateV 'eth_1273_4651' 'eth_4651_1273' '20' '61' '10.2.239.2/24' '10.2.239.1/24'
# node_1273-3216                                
echo "adding cluster edge node_1273-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_3216' 'eth_3216_1273' '20' 'None' '10.2.196.2/24' '10.2.196.1/24'
# node_1273-6453                                
echo "adding host edge node_1273-6453"                                
sleep 0.2                                
funCreateV 'eth_1273_6453' 'eth_6453_1273' '20' '22' '10.2.96.2/24' '10.2.96.1/24'
# node_1273-7473                                
echo "adding host edge node_1273-7473"                                
sleep 0.2                                
funCreateV 'eth_1273_7473' 'eth_7473_1273' '20' '80' '10.2.231.2/24' '10.2.231.1/24'
# node_1273-55410                                
echo "adding host edge node_1273-55410"                                
sleep 0.2                                
funCreateV 'eth_1273_55410' 'eth_55410_1273' '20' '41' '10.3.84.1/24' '10.3.84.2/24'
# node_1273-24785                                
echo "adding host edge node_1273-24785"                                
sleep 0.2                                
funCreateV 'eth_1273_24785' 'eth_24785_1273' '20' '86' '10.3.85.1/24' '10.3.85.2/24'
# node_1273-2497                                
echo "adding host edge node_1273-2497"                                
sleep 0.2                                
funCreateV 'eth_1273_2497' 'eth_2497_1273' '20' '42' '10.1.158.2/24' '10.1.158.1/24'
# node_1273-1239                                
echo "adding host edge node_1273-1239"                                
sleep 0.2                                
funCreateV 'eth_1273_1239' 'eth_1239_1273' '20' '21' '10.2.24.2/24' '10.2.24.1/24'
# node_1273-6939                                
echo "adding host edge node_1273-6939"                                
sleep 0.2                                
funCreateV 'eth_1273_6939' 'eth_6939_1273' '20' '27' '10.1.106.2/24' '10.1.106.1/24'
# node_1273-6461                                
echo "adding host edge node_1273-6461"                                
sleep 0.2                                
funCreateV 'eth_1273_6461' 'eth_6461_1273' '20' '25' '10.2.191.2/24' '10.2.191.1/24'
# node_1273-6830                                
echo "adding host edge node_1273-6830"                                
sleep 0.2                                
funCreateV 'eth_1273_6830' 'eth_6830_1273' '20' '92' '10.2.209.2/24' '10.2.209.1/24'
# node_1273-57304                                
echo "adding cluster edge node_1273-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_1273_57304' 'eth_57304_1273' '20' 'None' '10.3.86.1/24' '10.3.86.2/24'
# node_1273-55644                                
echo "adding host edge node_1273-55644"                                
sleep 0.2                                
funCreateV 'eth_1273_55644' 'eth_55644_1273' '20' '45' '10.3.87.1/24' '10.3.87.2/24'
# node_1239-3130                                
echo "adding cluster edge node_1239-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_1239_3130' 'eth_3130_1239' '21' 'None' '10.2.9.2/24' '10.2.9.1/24'
# node_1239-9304                                
echo "adding host edge node_1239-9304"                                
sleep 0.2                                
funCreateV 'eth_1239_9304' 'eth_9304_1239' '21' '60' '10.2.14.1/24' '10.2.14.2/24'
# node_1239-4766                                
echo "adding host edge node_1239-4766"                                
sleep 0.2                                
funCreateV 'eth_1239_4766' 'eth_4766_1239' '21' '35' '10.2.15.1/24' '10.2.15.2/24'
# node_1239-6453                                
echo "adding host edge node_1239-6453"                                
sleep 0.2                                
funCreateV 'eth_1239_6453' 'eth_6453_1239' '21' '22' '10.2.17.1/24' '10.2.17.2/24'
# node_1239-6939                                
echo "adding host edge node_1239-6939"                                
sleep 0.2                                
funCreateV 'eth_1239_6939' 'eth_6939_1239' '21' '27' '10.1.90.2/24' '10.1.90.1/24'
# node_1239-17676                                
echo "adding host edge node_1239-17676"                                
sleep 0.2                                
funCreateV 'eth_1239_17676' 'eth_17676_1239' '21' '79' '10.2.18.1/24' '10.2.18.2/24'
# node_1239-6461                                
echo "adding host edge node_1239-6461"                                
sleep 0.2                                
funCreateV 'eth_1239_6461' 'eth_6461_1239' '21' '25' '10.2.20.1/24' '10.2.20.2/24'
# node_1239-3491                                
echo "adding host edge node_1239-3491"                                
sleep 0.2                                
funCreateV 'eth_1239_3491' 'eth_3491_1239' '21' '26' '10.2.21.1/24' '10.2.21.2/24'
# node_1239-3786                                
echo "adding host edge node_1239-3786"                                
sleep 0.2                                
funCreateV 'eth_1239_3786' 'eth_3786_1239' '21' '30' '10.2.22.1/24' '10.2.22.2/24'
# node_1239-9318                                
echo "adding host edge node_1239-9318"                                
sleep 0.2                                
funCreateV 'eth_1239_9318' 'eth_9318_1239' '21' '64' '10.2.23.1/24' '10.2.23.2/24'
# node_1239-701                                
echo "adding host edge node_1239-701"                                
sleep 0.2                                
funCreateV 'eth_1239_701' 'eth_701_1239' '21' '32' '10.2.26.1/24' '10.2.26.2/24'
# node_1239-9929                                
echo "adding host edge node_1239-9929"                                
sleep 0.2                                
funCreateV 'eth_1239_9929' 'eth_9929_1239' '21' '97' '10.2.27.1/24' '10.2.27.2/24'
# node_1239-3462                                
echo "adding host edge node_1239-3462"                                
sleep 0.2                                
funCreateV 'eth_1239_3462' 'eth_3462_1239' '21' '67' '10.2.28.1/24' '10.2.28.2/24'
# node_1239-4775                                
echo "adding host edge node_1239-4775"                                
sleep 0.2                                
funCreateV 'eth_1239_4775' 'eth_4775_1239' '21' '44' '10.2.29.1/24' '10.2.29.2/24'
# node_1239-16509                                
echo "adding host edge node_1239-16509"                                
sleep 0.2                                
funCreateV 'eth_1239_16509' 'eth_16509_1239' '21' '46' '10.2.30.1/24' '10.2.30.2/24'
# node_1239-58453                                
echo "adding host edge node_1239-58453"                                
sleep 0.2                                
funCreateV 'eth_1239_58453' 'eth_58453_1239' '21' '68' '10.2.31.1/24' '10.2.31.2/24'
# node_1239-9605                                
echo "adding host edge node_1239-9605"                                
sleep 0.2                                
funCreateV 'eth_1239_9605' 'eth_9605_1239' '21' '69' '10.2.32.1/24' '10.2.32.2/24'
# node_1239-12479                                
echo "adding host edge node_1239-12479"                                
sleep 0.2                                
funCreateV 'eth_1239_12479' 'eth_12479_1239' '21' '53' '10.2.33.1/24' '10.2.33.2/24'
# node_6453-7545                                
echo "adding host edge node_6453-7545"                                
sleep 0.2                                
funCreateV 'eth_6453_7545' 'eth_7545_6453' '22' '83' '10.2.55.2/24' '10.2.55.1/24'
# node_6453-2497                                
echo "adding host edge node_6453-2497"                                
sleep 0.2                                
funCreateV 'eth_6453_2497' 'eth_2497_6453' '22' '42' '10.1.135.2/24' '10.1.135.1/24'
# node_6453-1403                                
echo "adding host edge node_6453-1403"                                
sleep 0.2                                
funCreateV 'eth_6453_1403' 'eth_1403_6453' '22' '78' '10.2.5.2/24' '10.2.5.1/24'
# node_6453-37100                                
echo "adding host edge node_6453-37100"                                
sleep 0.2                                
funCreateV 'eth_6453_37100' 'eth_37100_6453' '22' '29' '10.2.38.2/24' '10.2.38.1/24'
# node_6453-21859                                
echo "adding cluster edge node_6453-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_21859' 'eth_21859_6453' '22' 'None' '10.2.87.1/24' '10.2.87.2/24'
# node_6453-6461                                
echo "adding host edge node_6453-6461"                                
sleep 0.2                                
funCreateV 'eth_6453_6461' 'eth_6461_6453' '22' '25' '10.2.88.1/24' '10.2.88.2/24'
# node_6453-22652                                
echo "adding host edge node_6453-22652"                                
sleep 0.2                                
funCreateV 'eth_6453_22652' 'eth_22652_6453' '22' '75' '10.0.215.2/24' '10.0.215.1/24'
# node_6453-57866                                
echo "adding host edge node_6453-57866"                                
sleep 0.2                                
funCreateV 'eth_6453_57866' 'eth_57866_6453' '22' '37' '10.0.224.2/24' '10.0.224.1/24'
# node_6453-17676                                
echo "adding host edge node_6453-17676"                                
sleep 0.2                                
funCreateV 'eth_6453_17676' 'eth_17676_6453' '22' '79' '10.2.89.1/24' '10.2.89.2/24'
# node_6453-9583                                
echo "adding host edge node_6453-9583"                                
sleep 0.2                                
funCreateV 'eth_6453_9583' 'eth_9583_6453' '22' '85' '10.2.90.1/24' '10.2.90.2/24'
# node_6453-4755                                
echo "adding cluster edge node_6453-4755"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_4755' 'eth_4755_6453' '22' 'None' '10.2.91.1/24' '10.2.91.2/24'
# node_6453-4657                                
echo "adding host edge node_6453-4657"                                
sleep 0.2                                
funCreateV 'eth_6453_4657' 'eth_4657_6453' '22' '57' '10.2.92.1/24' '10.2.92.2/24'
# node_6453-57304                                
echo "adding cluster edge node_6453-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_57304' 'eth_57304_6453' '22' 'None' '10.2.93.1/24' '10.2.93.2/24'
# node_6453-23764                                
echo "adding host edge node_6453-23764"                                
sleep 0.2                                
funCreateV 'eth_6453_23764' 'eth_23764_6453' '22' '59' '10.2.94.1/24' '10.2.94.2/24'
# node_6453-7473                                
echo "adding host edge node_6453-7473"                                
sleep 0.2                                
funCreateV 'eth_6453_7473' 'eth_7473_6453' '22' '80' '10.2.97.1/24' '10.2.97.2/24'
# node_6453-4788                                
echo "adding host edge node_6453-4788"                                
sleep 0.2                                
funCreateV 'eth_6453_4788' 'eth_4788_6453' '22' '63' '10.2.98.1/24' '10.2.98.2/24'
# node_6453-4134                                
echo "adding host edge node_6453-4134"                                
sleep 0.2                                
funCreateV 'eth_6453_4134' 'eth_4134_6453' '22' '33' '10.2.99.1/24' '10.2.99.2/24'
# node_6453-9498                                
echo "adding host edge node_6453-9498"                                
sleep 0.2                                
funCreateV 'eth_6453_9498' 'eth_9498_6453' '22' '66' '10.2.100.1/24' '10.2.100.2/24'
# node_6453-9002                                
echo "adding host edge node_6453-9002"                                
sleep 0.2                                
funCreateV 'eth_6453_9002' 'eth_9002_6453' '22' '28' '10.2.101.1/24' '10.2.101.2/24'
# node_6453-3491                                
echo "adding host edge node_6453-3491"                                
sleep 0.2                                
funCreateV 'eth_6453_3491' 'eth_3491_6453' '22' '26' '10.2.102.1/24' '10.2.102.2/24'
# node_6453-2514                                
echo "adding cluster edge node_6453-2514"                                
sleep 0.2                                
funCreateClusterV 'eth_6453_2514' 'eth_2514_6453' '22' 'None' '10.2.103.1/24' '10.2.103.2/24'
# node_6453-4775                                
echo "adding host edge node_6453-4775"                                
sleep 0.2                                
funCreateV 'eth_6453_4775' 'eth_4775_6453' '22' '44' '10.2.104.1/24' '10.2.104.2/24'
# node_6453-16509                                
echo "adding host edge node_6453-16509"                                
sleep 0.2                                
funCreateV 'eth_6453_16509' 'eth_16509_6453' '22' '46' '10.2.105.1/24' '10.2.105.2/24'
# node_6453-4538                                
echo "adding host edge node_6453-4538"                                
sleep 0.2                                
funCreateV 'eth_6453_4538' 'eth_4538_6453' '22' '90' '10.2.106.1/24' '10.2.106.2/24'
# node_6453-18403                                
echo "adding host edge node_6453-18403"                                
sleep 0.2                                
funCreateV 'eth_6453_18403' 'eth_18403_6453' '22' '47' '10.2.107.1/24' '10.2.107.2/24'
# node_6453-4637                                
echo "adding host edge node_6453-4637"                                
sleep 0.2                                
funCreateV 'eth_6453_4637' 'eth_4637_6453' '22' '49' '10.2.108.1/24' '10.2.108.2/24'
# node_6453-4651                                
echo "adding host edge node_6453-4651"                                
sleep 0.2                                
funCreateV 'eth_6453_4651' 'eth_4651_6453' '22' '61' '10.2.110.1/24' '10.2.110.2/24'
# node_6453-3786                                
echo "adding host edge node_6453-3786"                                
sleep 0.2                                
funCreateV 'eth_6453_3786' 'eth_3786_6453' '22' '30' '10.2.111.1/24' '10.2.111.2/24'
# node_31133-8492                                
echo "adding host edge node_31133-8492"                                
sleep 0.2                                
funCreateV 'eth_31133_8492' 'eth_8492_31133' '23' '76' '10.0.228.2/24' '10.0.228.1/24'
# node_31133-4637                                
echo "adding host edge node_31133-4637"                                
sleep 0.2                                
funCreateV 'eth_31133_4637' 'eth_4637_31133' '23' '49' '10.2.135.2/24' '10.2.135.1/24'
# node_31133-3786                                
echo "adding host edge node_31133-3786"                                
sleep 0.2                                
funCreateV 'eth_31133_3786' 'eth_3786_31133' '23' '30' '10.2.148.1/24' '10.2.148.2/24'
# node_31133-4134                                
echo "adding host edge node_31133-4134"                                
sleep 0.2                                
funCreateV 'eth_31133_4134' 'eth_4134_31133' '23' '33' '10.2.149.1/24' '10.2.149.2/24'
# node_31133-4766                                
echo "adding host edge node_31133-4766"                                
sleep 0.2                                
funCreateV 'eth_31133_4766' 'eth_4766_31133' '23' '35' '10.2.150.1/24' '10.2.150.2/24'
# node_31133-9318                                
echo "adding host edge node_31133-9318"                                
sleep 0.2                                
funCreateV 'eth_31133_9318' 'eth_9318_31133' '23' '64' '10.2.151.1/24' '10.2.151.2/24'
# node_31133-8763                                
echo "adding host edge node_31133-8763"                                
sleep 0.2                                
funCreateV 'eth_31133_8763' 'eth_8763_31133' '23' '65' '10.2.152.1/24' '10.2.152.2/24'
# node_31133-9498                                
echo "adding host edge node_31133-9498"                                
sleep 0.2                                
funCreateV 'eth_31133_9498' 'eth_9498_31133' '23' '66' '10.2.153.1/24' '10.2.153.2/24'
# node_31133-58453                                
echo "adding host edge node_31133-58453"                                
sleep 0.2                                
funCreateV 'eth_31133_58453' 'eth_58453_31133' '23' '68' '10.2.154.1/24' '10.2.154.2/24'
# node_31133-23764                                
echo "adding host edge node_31133-23764"                                
sleep 0.2                                
funCreateV 'eth_31133_23764' 'eth_23764_31133' '23' '59' '10.2.155.1/24' '10.2.155.2/24'
# node_31133-18403                                
echo "adding host edge node_31133-18403"                                
sleep 0.2                                
funCreateV 'eth_31133_18403' 'eth_18403_31133' '23' '47' '10.2.156.1/24' '10.2.156.2/24'
# node_31133-10158                                
echo "adding host edge node_31133-10158"                                
sleep 0.2                                
funCreateV 'eth_31133_10158' 'eth_10158_31133' '23' '70' '10.2.157.1/24' '10.2.157.2/24'
# node_64049-37100                                
echo "adding host edge node_64049-37100"                                
sleep 0.2                                
funCreateV 'eth_64049_37100' 'eth_37100_64049' '24' '29' '10.2.43.2/24' '10.2.43.1/24'
# node_64049-55836                                
echo "adding cluster edge node_64049-55836"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_55836' 'eth_55836_64049' '24' 'None' '10.3.115.1/24' '10.3.115.2/24'
# node_64049-6939                                
echo "adding host edge node_64049-6939"                                
sleep 0.2                                
funCreateV 'eth_64049_6939' 'eth_6939_64049' '24' '27' '10.1.92.2/24' '10.1.92.1/24'
# node_64049-12552                                
echo "adding host edge node_64049-12552"                                
sleep 0.2                                
funCreateV 'eth_64049_12552' 'eth_12552_64049' '24' '36' '10.2.118.2/24' '10.2.118.1/24'
# node_64049-18106                                
echo "adding host edge node_64049-18106"                                
sleep 0.2                                
funCreateV 'eth_64049_18106' 'eth_18106_64049' '24' '73' '10.0.184.2/24' '10.0.184.1/24'
# node_64049-22652                                
echo "adding host edge node_64049-22652"                                
sleep 0.2                                
funCreateV 'eth_64049_22652' 'eth_22652_64049' '24' '75' '10.0.217.2/24' '10.0.217.1/24'
# node_64049-23673                                
echo "adding host edge node_64049-23673"                                
sleep 0.2                                
funCreateV 'eth_64049_23673' 'eth_23673_64049' '24' '77' '10.1.248.2/24' '10.1.248.1/24'
# node_64049-20764                                
echo "adding host edge node_64049-20764"                                
sleep 0.2                                
funCreateV 'eth_64049_20764' 'eth_20764_64049' '24' '93' '10.3.116.1/24' '10.3.116.2/24'
# node_64049-57304                                
echo "adding cluster edge node_64049-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_64049_57304' 'eth_57304_64049' '24' 'None' '10.3.109.2/24' '10.3.109.1/24'
# node_6461-11686                                
echo "adding host edge node_6461-11686"                                
sleep 0.2                                
funCreateV 'eth_6461_11686' 'eth_11686_6461' '25' '74' '10.0.210.2/24' '10.0.210.1/24'
# node_6461-57866                                
echo "adding host edge node_6461-57866"                                
sleep 0.2                                
funCreateV 'eth_6461_57866' 'eth_57866_6461' '25' '37' '10.0.223.2/24' '10.0.223.1/24'
# node_6461-7473                                
echo "adding host edge node_6461-7473"                                
sleep 0.2                                
funCreateV 'eth_6461_7473' 'eth_7473_6461' '25' '80' '10.2.182.1/24' '10.2.182.2/24'
# node_6461-17676                                
echo "adding host edge node_6461-17676"                                
sleep 0.2                                
funCreateV 'eth_6461_17676' 'eth_17676_6461' '25' '79' '10.2.184.1/24' '10.2.184.2/24'
# node_6461-1403                                
echo "adding host edge node_6461-1403"                                
sleep 0.2                                
funCreateV 'eth_6461_1403' 'eth_1403_6461' '25' '78' '10.2.6.2/24' '10.2.6.1/24'
# node_6461-5413                                
echo "adding host edge node_6461-5413"                                
sleep 0.2                                
funCreateV 'eth_6461_5413' 'eth_5413_6461' '25' '31' '10.1.187.2/24' '10.1.187.1/24'
# node_6461-37100                                
echo "adding host edge node_6461-37100"                                
sleep 0.2                                
funCreateV 'eth_6461_37100' 'eth_37100_6461' '25' '29' '10.2.42.2/24' '10.2.42.1/24'
# node_6461-12552                                
echo "adding host edge node_6461-12552"                                
sleep 0.2                                
funCreateV 'eth_6461_12552' 'eth_12552_6461' '25' '36' '10.2.119.2/24' '10.2.119.1/24'
# node_6461-3491                                
echo "adding host edge node_6461-3491"                                
sleep 0.2                                
funCreateV 'eth_6461_3491' 'eth_3491_6461' '25' '26' '10.2.185.1/24' '10.2.185.2/24'
# node_6461-9318                                
echo "adding host edge node_6461-9318"                                
sleep 0.2                                
funCreateV 'eth_6461_9318' 'eth_9318_6461' '25' '64' '10.2.186.1/24' '10.2.186.2/24'
# node_6461-4134                                
echo "adding host edge node_6461-4134"                                
sleep 0.2                                
funCreateV 'eth_6461_4134' 'eth_4134_6461' '25' '33' '10.2.187.1/24' '10.2.187.2/24'
# node_6461-132203                                
echo "adding host edge node_6461-132203"                                
sleep 0.2                                
funCreateV 'eth_6461_132203' 'eth_132203_6461' '25' '34' '10.2.188.1/24' '10.2.188.2/24'
# node_6461-20562                                
echo "adding cluster edge node_6461-20562"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_20562' 'eth_20562_6461' '25' 'None' '10.2.189.1/24' '10.2.189.2/24'
# node_6461-9498                                
echo "adding host edge node_6461-9498"                                
sleep 0.2                                
funCreateV 'eth_6461_9498' 'eth_9498_6461' '25' '66' '10.2.190.1/24' '10.2.190.2/24'
# node_6461-9002                                
echo "adding host edge node_6461-9002"                                
sleep 0.2                                
funCreateV 'eth_6461_9002' 'eth_9002_6461' '25' '28' '10.2.192.1/24' '10.2.192.2/24'
# node_6461-9680                                
echo "adding host edge node_6461-9680"                                
sleep 0.2                                
funCreateV 'eth_6461_9680' 'eth_9680_6461' '25' '43' '10.2.193.1/24' '10.2.193.2/24'
# node_6461-6939                                
echo "adding host edge node_6461-6939"                                
sleep 0.2                                
funCreateV 'eth_6461_6939' 'eth_6939_6461' '25' '27' '10.1.118.2/24' '10.1.118.1/24'
# node_6461-57304                                
echo "adding cluster edge node_6461-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_6461_57304' 'eth_57304_6461' '25' 'None' '10.2.194.1/24' '10.2.194.2/24'
# node_6461-2497                                
echo "adding host edge node_6461-2497"                                
sleep 0.2                                
funCreateV 'eth_6461_2497' 'eth_2497_6461' '25' '42' '10.1.163.2/24' '10.1.163.1/24'
# node_6461-4637                                
echo "adding host edge node_6461-4637"                                
sleep 0.2                                
funCreateV 'eth_6461_4637' 'eth_4637_6461' '25' '49' '10.2.147.2/24' '10.2.147.1/24'
# node_3491-21859                                
echo "adding cluster edge node_3491-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_21859' 'eth_21859_3491' '26' 'None' '10.3.40.2/24' '10.3.40.1/24'
# node_3491-11164                                
echo "adding cluster edge node_3491-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_11164' 'eth_11164_3491' '26' 'None' '10.2.158.2/24' '10.2.158.1/24'
# node_3491-2497                                
echo "adding host edge node_3491-2497"                                
sleep 0.2                                
funCreateV 'eth_3491_2497' 'eth_2497_3491' '26' '42' '10.1.147.2/24' '10.1.147.1/24'
# node_3491-9583                                
echo "adding host edge node_3491-9583"                                
sleep 0.2                                
funCreateV 'eth_3491_9583' 'eth_9583_3491' '26' '85' '10.3.45.1/24' '10.3.45.2/24'
# node_3491-6939                                
echo "adding host edge node_3491-6939"                                
sleep 0.2                                
funCreateV 'eth_3491_6939' 'eth_6939_3491' '26' '27' '10.1.93.2/24' '10.1.93.1/24'
# node_3491-7497                                
echo "adding host edge node_3491-7497"                                
sleep 0.2                                
funCreateV 'eth_3491_7497' 'eth_7497_3491' '26' '96' '10.3.46.1/24' '10.3.46.2/24'
# node_3491-6830                                
echo "adding host edge node_3491-6830"                                
sleep 0.2                                
funCreateV 'eth_3491_6830' 'eth_6830_3491' '26' '92' '10.2.204.2/24' '10.2.204.1/24'
# node_3491-20485                                
echo "adding host edge node_3491-20485"                                
sleep 0.2                                
funCreateV 'eth_3491_20485' 'eth_20485_3491' '26' '95' '10.3.28.2/24' '10.3.28.1/24'
# node_3491-4651                                
echo "adding host edge node_3491-4651"                                
sleep 0.2                                
funCreateV 'eth_3491_4651' 'eth_4651_3491' '26' '61' '10.2.240.2/24' '10.2.240.1/24'
# node_3491-132203                                
echo "adding host edge node_3491-132203"                                
sleep 0.2                                
funCreateV 'eth_3491_132203' 'eth_132203_3491' '26' '34' '10.3.47.1/24' '10.3.47.2/24'
# node_3491-9498                                
echo "adding host edge node_3491-9498"                                
sleep 0.2                                
funCreateV 'eth_3491_9498' 'eth_9498_3491' '26' '66' '10.3.48.1/24' '10.3.48.2/24'
# node_3491-64050                                
echo "adding host edge node_3491-64050"                                
sleep 0.2                                
funCreateV 'eth_3491_64050' 'eth_64050_3491' '26' '87' '10.3.49.1/24' '10.3.49.2/24'
# node_3491-4760                                
echo "adding cluster edge node_3491-4760"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_4760' 'eth_4760_3491' '26' 'None' '10.3.50.1/24' '10.3.50.2/24'
# node_3491-5413                                
echo "adding host edge node_3491-5413"                                
sleep 0.2                                
funCreateV 'eth_3491_5413' 'eth_5413_3491' '26' '31' '10.1.191.2/24' '10.1.191.1/24'
# node_3491-55644                                
echo "adding host edge node_3491-55644"                                
sleep 0.2                                
funCreateV 'eth_3491_55644' 'eth_55644_3491' '26' '45' '10.3.51.1/24' '10.3.51.2/24'
# node_3491-4538                                
echo "adding host edge node_3491-4538"                                
sleep 0.2                                
funCreateV 'eth_3491_4538' 'eth_4538_3491' '26' '90' '10.3.52.1/24' '10.3.52.2/24'
# node_3491-18403                                
echo "adding host edge node_3491-18403"                                
sleep 0.2                                
funCreateV 'eth_3491_18403' 'eth_18403_3491' '26' '47' '10.3.53.1/24' '10.3.53.2/24'
# node_3491-38819                                
echo "adding cluster edge node_3491-38819"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_38819' 'eth_38819_3491' '26' 'None' '10.3.54.1/24' '10.3.54.2/24'
# node_3491-23764                                
echo "adding host edge node_3491-23764"                                
sleep 0.2                                
funCreateV 'eth_3491_23764' 'eth_23764_3491' '26' '59' '10.3.55.1/24' '10.3.55.2/24'
# node_3491-4809                                
echo "adding host edge node_3491-4809"                                
sleep 0.2                                
funCreateV 'eth_3491_4809' 'eth_4809_3491' '26' '48' '10.3.56.1/24' '10.3.56.2/24'
# node_3491-4826                                
echo "adding host edge node_3491-4826"                                
sleep 0.2                                
funCreateV 'eth_3491_4826' 'eth_4826_3491' '26' '91' '10.3.57.1/24' '10.3.57.2/24'
# node_3491-9924                                
echo "adding cluster edge node_3491-9924"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_9924' 'eth_9924_3491' '26' 'None' '10.3.58.1/24' '10.3.58.2/24'
# node_3491-10158                                
echo "adding host edge node_3491-10158"                                
sleep 0.2                                
funCreateV 'eth_3491_10158' 'eth_10158_3491' '26' '70' '10.3.59.1/24' '10.3.59.2/24'
# node_3491-9848                                
echo "adding cluster edge node_3491-9848"                                
sleep 0.2                                
funCreateClusterV 'eth_3491_9848' 'eth_9848_3491' '26' 'None' '10.3.60.1/24' '10.3.60.2/24'
# node_6939-20130                                
echo "adding cluster edge node_6939-20130"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_20130' 'eth_20130_6939' '27' 'None' '10.1.73.2/24' '10.1.73.1/24'
# node_6939-37100                                
echo "adding host edge node_6939-37100"                                
sleep 0.2                                
funCreateV 'eth_6939_37100' 'eth_37100_6939' '27' '29' '10.1.75.1/24' '10.1.75.2/24'
# node_6939-7545                                
echo "adding host edge node_6939-7545"                                
sleep 0.2                                
funCreateV 'eth_6939_7545' 'eth_7545_6939' '27' '83' '10.1.76.1/24' '10.1.76.2/24'
# node_6939-53767                                
echo "adding cluster edge node_6939-53767"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_53767' 'eth_53767_6939' '27' 'None' '10.1.77.1/24' '10.1.77.2/24'
# node_6939-5413                                
echo "adding host edge node_6939-5413"                                
sleep 0.2                                
funCreateV 'eth_6939_5413' 'eth_5413_6939' '27' '31' '10.1.78.1/24' '10.1.78.2/24'
# node_6939-49788                                
echo "adding host edge node_6939-49788"                                
sleep 0.2                                
funCreateV 'eth_6939_49788' 'eth_49788_6939' '27' '72' '10.0.155.2/24' '10.0.155.1/24'
# node_6939-1403                                
echo "adding host edge node_6939-1403"                                
sleep 0.2                                
funCreateV 'eth_6939_1403' 'eth_1403_6939' '27' '78' '10.1.79.1/24' '10.1.79.2/24'
# node_6939-3130                                
echo "adding cluster edge node_6939-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_3130' 'eth_3130_6939' '27' 'None' '10.1.80.1/24' '10.1.80.2/24'
# node_6939-20912                                
echo "adding host edge node_6939-20912"                                
sleep 0.2                                
funCreateV 'eth_6939_20912' 'eth_20912_6939' '27' '71' '10.0.121.2/24' '10.0.121.1/24'
# node_6939-18106                                
echo "adding host edge node_6939-18106"                                
sleep 0.2                                
funCreateV 'eth_6939_18106' 'eth_18106_6939' '27' '73' '10.0.175.2/24' '10.0.175.1/24'
# node_6939-11686                                
echo "adding host edge node_6939-11686"                                
sleep 0.2                                
funCreateV 'eth_6939_11686' 'eth_11686_6939' '27' '74' '10.0.208.2/24' '10.0.208.1/24'
# node_6939-22652                                
echo "adding host edge node_6939-22652"                                
sleep 0.2                                
funCreateV 'eth_6939_22652' 'eth_22652_6939' '27' '75' '10.0.213.2/24' '10.0.213.1/24'
# node_6939-8492                                
echo "adding host edge node_6939-8492"                                
sleep 0.2                                
funCreateV 'eth_6939_8492' 'eth_8492_6939' '27' '76' '10.0.227.2/24' '10.0.227.1/24'
# node_6939-23673                                
echo "adding host edge node_6939-23673"                                
sleep 0.2                                
funCreateV 'eth_6939_23673' 'eth_23673_6939' '27' '77' '10.1.82.1/24' '10.1.82.2/24'
# node_6939-15412                                
echo "adding host edge node_6939-15412"                                
sleep 0.2                                
funCreateV 'eth_6939_15412' 'eth_15412_6939' '27' '84' '10.1.84.1/24' '10.1.84.2/24'
# node_6939-7670                                
echo "adding host edge node_6939-7670"                                
sleep 0.2                                
funCreateV 'eth_6939_7670' 'eth_7670_6939' '27' '98' '10.1.85.1/24' '10.1.85.2/24'
# node_6939-4651                                
echo "adding host edge node_6939-4651"                                
sleep 0.2                                
funCreateV 'eth_6939_4651' 'eth_4651_6939' '27' '61' '10.1.87.1/24' '10.1.87.2/24'
# node_6939-21859                                
echo "adding cluster edge node_6939-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_21859' 'eth_21859_6939' '27' 'None' '10.1.89.1/24' '10.1.89.2/24'
# node_6939-9583                                
echo "adding host edge node_6939-9583"                                
sleep 0.2                                
funCreateV 'eth_6939_9583' 'eth_9583_6939' '27' '85' '10.1.91.1/24' '10.1.91.2/24'
# node_6939-4788                                
echo "adding host edge node_6939-4788"                                
sleep 0.2                                
funCreateV 'eth_6939_4788' 'eth_4788_6939' '27' '63' '10.1.94.1/24' '10.1.94.2/24'
# node_6939-2497                                
echo "adding host edge node_6939-2497"                                
sleep 0.2                                
funCreateV 'eth_6939_2497' 'eth_2497_6939' '27' '42' '10.1.95.1/24' '10.1.95.2/24'
# node_6939-3786                                
echo "adding host edge node_6939-3786"                                
sleep 0.2                                
funCreateV 'eth_6939_3786' 'eth_3786_6939' '27' '30' '10.1.96.1/24' '10.1.96.2/24'
# node_6939-38091                                
echo "adding cluster edge node_6939-38091"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_38091' 'eth_38091_6939' '27' 'None' '10.1.97.1/24' '10.1.97.2/24'
# node_6939-9318                                
echo "adding host edge node_6939-9318"                                
sleep 0.2                                
funCreateV 'eth_6939_9318' 'eth_9318_6939' '27' '64' '10.1.98.1/24' '10.1.98.2/24'
# node_6939-4134                                
echo "adding host edge node_6939-4134"                                
sleep 0.2                                
funCreateV 'eth_6939_4134' 'eth_4134_6939' '27' '33' '10.1.99.1/24' '10.1.99.2/24'
# node_6939-132203                                
echo "adding host edge node_6939-132203"                                
sleep 0.2                                
funCreateV 'eth_6939_132203' 'eth_132203_6939' '27' '34' '10.1.100.1/24' '10.1.100.2/24'
# node_6939-4766                                
echo "adding host edge node_6939-4766"                                
sleep 0.2                                
funCreateV 'eth_6939_4766' 'eth_4766_6939' '27' '35' '10.1.101.1/24' '10.1.101.2/24'
# node_6939-12552                                
echo "adding host edge node_6939-12552"                                
sleep 0.2                                
funCreateV 'eth_6939_12552' 'eth_12552_6939' '27' '36' '10.1.102.1/24' '10.1.102.2/24'
# node_6939-22548                                
echo "adding cluster edge node_6939-22548"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_22548' 'eth_22548_6939' '27' 'None' '10.1.103.1/24' '10.1.103.2/24'
# node_6939-8763                                
echo "adding host edge node_6939-8763"                                
sleep 0.2                                
funCreateV 'eth_6939_8763' 'eth_8763_6939' '27' '65' '10.1.104.1/24' '10.1.104.2/24'
# node_6939-59125                                
echo "adding cluster edge node_6939-59125"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_59125' 'eth_59125_6939' '27' 'None' '10.1.105.1/24' '10.1.105.2/24'
# node_6939-9498                                
echo "adding host edge node_6939-9498"                                
sleep 0.2                                
funCreateV 'eth_6939_9498' 'eth_9498_6939' '27' '66' '10.1.107.1/24' '10.1.107.2/24'
# node_6939-701                                
echo "adding host edge node_6939-701"                                
sleep 0.2                                
funCreateV 'eth_6939_701' 'eth_701_6939' '27' '32' '10.1.109.1/24' '10.1.109.2/24'
# node_6939-64050                                
echo "adding host edge node_6939-64050"                                
sleep 0.2                                
funCreateV 'eth_6939_64050' 'eth_64050_6939' '27' '87' '10.1.110.1/24' '10.1.110.2/24'
# node_6939-9002                                
echo "adding host edge node_6939-9002"                                
sleep 0.2                                
funCreateV 'eth_6939_9002' 'eth_9002_6939' '27' '28' '10.1.111.1/24' '10.1.111.2/24'
# node_6939-7473                                
echo "adding host edge node_6939-7473"                                
sleep 0.2                                
funCreateV 'eth_6939_7473' 'eth_7473_6939' '27' '80' '10.1.112.1/24' '10.1.112.2/24'
# node_6939-2514                                
echo "adding cluster edge node_6939-2514"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_2514' 'eth_2514_6939' '27' 'None' '10.1.113.1/24' '10.1.113.2/24'
# node_6939-9680                                
echo "adding host edge node_6939-9680"                                
sleep 0.2                                
funCreateV 'eth_6939_9680' 'eth_9680_6939' '27' '43' '10.1.114.1/24' '10.1.114.2/24'
# node_6939-3462                                
echo "adding host edge node_6939-3462"                                
sleep 0.2                                
funCreateV 'eth_6939_3462' 'eth_3462_6939' '27' '67' '10.1.115.1/24' '10.1.115.2/24'
# node_6939-4760                                
echo "adding cluster edge node_6939-4760"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_4760' 'eth_4760_6939' '27' 'None' '10.1.116.1/24' '10.1.116.2/24'
# node_6939-4775                                
echo "adding host edge node_6939-4775"                                
sleep 0.2                                
funCreateV 'eth_6939_4775' 'eth_4775_6939' '27' '44' '10.1.117.1/24' '10.1.117.2/24'
# node_6939-16509                                
echo "adding host edge node_6939-16509"                                
sleep 0.2                                
funCreateV 'eth_6939_16509' 'eth_16509_6939' '27' '46' '10.1.119.1/24' '10.1.119.2/24'
# node_6939-10089                                
echo "adding host edge node_6939-10089"                                
sleep 0.2                                
funCreateV 'eth_6939_10089' 'eth_10089_6939' '27' '88' '10.1.120.1/24' '10.1.120.2/24'
# node_6939-4538                                
echo "adding host edge node_6939-4538"                                
sleep 0.2                                
funCreateV 'eth_6939_4538' 'eth_4538_6939' '27' '90' '10.1.121.1/24' '10.1.121.2/24'
# node_6939-23764                                
echo "adding host edge node_6939-23764"                                
sleep 0.2                                
funCreateV 'eth_6939_23764' 'eth_23764_6939' '27' '59' '10.1.122.1/24' '10.1.122.2/24'
# node_6939-18403                                
echo "adding host edge node_6939-18403"                                
sleep 0.2                                
funCreateV 'eth_6939_18403' 'eth_18403_6939' '27' '47' '10.1.123.1/24' '10.1.123.2/24'
# node_6939-9605                                
echo "adding host edge node_6939-9605"                                
sleep 0.2                                
funCreateV 'eth_6939_9605' 'eth_9605_6939' '27' '69' '10.1.124.1/24' '10.1.124.2/24'
# node_6939-4809                                
echo "adding host edge node_6939-4809"                                
sleep 0.2                                
funCreateV 'eth_6939_4809' 'eth_4809_6939' '27' '48' '10.1.125.1/24' '10.1.125.2/24'
# node_6939-17676                                
echo "adding host edge node_6939-17676"                                
sleep 0.2                                
funCreateV 'eth_6939_17676' 'eth_17676_6939' '27' '79' '10.1.126.1/24' '10.1.126.2/24'
# node_6939-137753                                
echo "adding cluster edge node_6939-137753"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_137753' 'eth_137753_6939' '27' 'None' '10.1.127.1/24' '10.1.127.2/24'
# node_6939-4637                                
echo "adding host edge node_6939-4637"                                
sleep 0.2                                
funCreateV 'eth_6939_4637' 'eth_4637_6939' '27' '49' '10.1.128.1/24' '10.1.128.2/24'
# node_6939-4826                                
echo "adding host edge node_6939-4826"                                
sleep 0.2                                
funCreateV 'eth_6939_4826' 'eth_4826_6939' '27' '91' '10.1.129.1/24' '10.1.129.2/24'
# node_6939-136907                                
echo "adding host edge node_6939-136907"                                
sleep 0.2                                
funCreateV 'eth_6939_136907' 'eth_136907_6939' '27' '50' '10.1.130.1/24' '10.1.130.2/24'
# node_6939-12479                                
echo "adding host edge node_6939-12479"                                
sleep 0.2                                
funCreateV 'eth_6939_12479' 'eth_12479_6939' '27' '53' '10.1.132.1/24' '10.1.132.2/24'
# node_6939-15169                                
echo "adding host edge node_6939-15169"                                
sleep 0.2                                
funCreateV 'eth_6939_15169' 'eth_15169_6939' '27' '54' '10.1.133.1/24' '10.1.133.2/24'
# node_6939-24157                                
echo "adding cluster edge node_6939-24157"                                
sleep 0.2                                
funCreateClusterV 'eth_6939_24157' 'eth_24157_6939' '27' 'None' '10.1.134.1/24' '10.1.134.2/24'
# node_9002-57866                                
echo "adding host edge node_9002-57866"                                
sleep 0.2                                
funCreateV 'eth_9002_57866' 'eth_57866_9002' '28' '37' '10.0.225.2/24' '10.0.225.1/24'
# node_9002-4651                                
echo "adding host edge node_9002-4651"                                
sleep 0.2                                
funCreateV 'eth_9002_4651' 'eth_4651_9002' '28' '61' '10.2.241.2/24' '10.2.241.1/24'
# node_9002-3130                                
echo "adding cluster edge node_9002-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_9002_3130' 'eth_3130_9002' '28' 'None' '10.2.11.2/24' '10.2.11.1/24'
# node_9002-64050                                
echo "adding host edge node_9002-64050"                                
sleep 0.2                                
funCreateV 'eth_9002_64050' 'eth_64050_9002' '28' '87' '10.3.34.1/24' '10.3.34.2/24'
# node_9002-12552                                
echo "adding host edge node_9002-12552"                                
sleep 0.2                                
funCreateV 'eth_9002_12552' 'eth_12552_9002' '28' '36' '10.2.124.2/24' '10.2.124.1/24'
# node_9002-5413                                
echo "adding host edge node_9002-5413"                                
sleep 0.2                                
funCreateV 'eth_9002_5413' 'eth_5413_9002' '28' '31' '10.1.190.2/24' '10.1.190.1/24'
# node_9002-18106                                
echo "adding host edge node_9002-18106"                                
sleep 0.2                                
funCreateV 'eth_9002_18106' 'eth_18106_9002' '28' '73' '10.0.193.2/24' '10.0.193.1/24'
# node_37100-2497                                
echo "adding host edge node_37100-2497"                                
sleep 0.2                                
funCreateV 'eth_37100_2497' 'eth_2497_37100' '29' '42' '10.1.136.2/24' '10.1.136.1/24'
# node_37100-9304                                
echo "adding host edge node_37100-9304"                                
sleep 0.2                                
funCreateV 'eth_37100_9304' 'eth_9304_37100' '29' '60' '10.2.36.1/24' '10.2.36.2/24'
# node_37100-4651                                
echo "adding host edge node_37100-4651"                                
sleep 0.2                                
funCreateV 'eth_37100_4651' 'eth_4651_37100' '29' '61' '10.2.37.1/24' '10.2.37.2/24'
# node_37100-9583                                
echo "adding host edge node_37100-9583"                                
sleep 0.2                                
funCreateV 'eth_37100_9583' 'eth_9583_37100' '29' '85' '10.2.39.1/24' '10.2.39.2/24'
# node_37100-4788                                
echo "adding host edge node_37100-4788"                                
sleep 0.2                                
funCreateV 'eth_37100_4788' 'eth_4788_37100' '29' '63' '10.2.44.1/24' '10.2.44.2/24'
# node_37100-132203                                
echo "adding host edge node_37100-132203"                                
sleep 0.2                                
funCreateV 'eth_37100_132203' 'eth_132203_37100' '29' '34' '10.2.45.1/24' '10.2.45.2/24'
# node_37100-9318                                
echo "adding host edge node_37100-9318"                                
sleep 0.2                                
funCreateV 'eth_37100_9318' 'eth_9318_37100' '29' '64' '10.2.46.1/24' '10.2.46.2/24'
# node_37100-13237                                
echo "adding cluster edge node_37100-13237"                                
sleep 0.2                                
funCreateClusterV 'eth_37100_13237' 'eth_13237_37100' '29' 'None' '10.2.47.1/24' '10.2.47.2/24'
# node_37100-9498                                
echo "adding host edge node_37100-9498"                                
sleep 0.2                                
funCreateV 'eth_37100_9498' 'eth_9498_37100' '29' '66' '10.2.48.1/24' '10.2.48.2/24'
# node_37100-3462                                
echo "adding host edge node_37100-3462"                                
sleep 0.2                                
funCreateV 'eth_37100_3462' 'eth_3462_37100' '29' '67' '10.2.49.1/24' '10.2.49.2/24'
# node_37100-4775                                
echo "adding host edge node_37100-4775"                                
sleep 0.2                                
funCreateV 'eth_37100_4775' 'eth_4775_37100' '29' '44' '10.2.50.1/24' '10.2.50.2/24'
# node_37100-23764                                
echo "adding host edge node_37100-23764"                                
sleep 0.2                                
funCreateV 'eth_37100_23764' 'eth_23764_37100' '29' '59' '10.2.51.1/24' '10.2.51.2/24'
# node_37100-15169                                
echo "adding host edge node_37100-15169"                                
sleep 0.2                                
funCreateV 'eth_37100_15169' 'eth_15169_37100' '29' '54' '10.2.52.1/24' '10.2.52.2/24'
# node_3786-38091                                
echo "adding cluster edge node_3786-38091"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_38091' 'eth_38091_3786' '30' 'None' '10.3.133.1/24' '10.3.133.2/24'
# node_3786-6830                                
echo "adding host edge node_3786-6830"                                
sleep 0.2                                
funCreateV 'eth_3786_6830' 'eth_6830_3786' '30' '92' '10.2.205.2/24' '10.2.205.1/24'
# node_3786-2497                                
echo "adding host edge node_3786-2497"                                
sleep 0.2                                
funCreateV 'eth_3786_2497' 'eth_2497_3786' '30' '42' '10.1.151.2/24' '10.1.151.1/24'
# node_3786-4657                                
echo "adding host edge node_3786-4657"                                
sleep 0.2                                
funCreateV 'eth_3786_4657' 'eth_4657_3786' '30' '57' '10.3.24.2/24' '10.3.24.1/24'
# node_3786-131099                                
echo "adding cluster edge node_3786-131099"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_131099' 'eth_131099_3786' '30' 'None' '10.3.134.1/24' '10.3.134.2/24'
# node_3786-57304                                
echo "adding cluster edge node_3786-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_57304' 'eth_57304_3786' '30' 'None' '10.3.110.2/24' '10.3.110.1/24'
# node_3786-9858                                
echo "adding cluster edge node_3786-9858"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_9858' 'eth_9858_3786' '30' 'None' '10.3.135.1/24' '10.3.135.2/24'
# node_3786-64050                                
echo "adding host edge node_3786-64050"                                
sleep 0.2                                
funCreateV 'eth_3786_64050' 'eth_64050_3786' '30' '87' '10.3.136.1/24' '10.3.136.2/24'
# node_3786-9318                                
echo "adding host edge node_3786-9318"                                
sleep 0.2                                
funCreateV 'eth_3786_9318' 'eth_9318_3786' '30' '64' '10.3.137.1/24' '10.3.137.2/24'
# node_3786-9286                                
echo "adding cluster edge node_3786-9286"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_9286' 'eth_9286_3786' '30' 'None' '10.3.138.1/24' '10.3.138.2/24'
# node_3786-4637                                
echo "adding host edge node_3786-4637"                                
sleep 0.2                                
funCreateV 'eth_3786_4637' 'eth_4637_3786' '30' '49' '10.2.146.2/24' '10.2.146.1/24'
# node_3786-4791                                
echo "adding cluster edge node_3786-4791"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_4791' 'eth_4791_3786' '30' 'None' '10.3.139.1/24' '10.3.139.2/24'
# node_3786-18305                                
echo "adding cluster edge node_3786-18305"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_18305' 'eth_18305_3786' '30' 'None' '10.3.140.1/24' '10.3.140.2/24'
# node_3786-18176                                
echo "adding cluster edge node_3786-18176"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_18176' 'eth_18176_3786' '30' 'None' '10.3.141.1/24' '10.3.141.2/24'
# node_3786-10190                                
echo "adding cluster edge node_3786-10190"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_10190' 'eth_10190_3786' '30' 'None' '10.3.142.1/24' '10.3.142.2/24'
# node_3786-38707                                
echo "adding cluster edge node_3786-38707"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_38707' 'eth_38707_3786' '30' 'None' '10.3.143.1/24' '10.3.143.2/24'
# node_3786-55627                                
echo "adding cluster edge node_3786-55627"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_55627' 'eth_55627_3786' '30' 'None' '10.3.144.1/24' '10.3.144.2/24'
# node_3786-7562                                
echo "adding cluster edge node_3786-7562"                                
sleep 0.2                                
funCreateClusterV 'eth_3786_7562' 'eth_7562_3786' '30' 'None' '10.3.145.1/24' '10.3.145.2/24'
# node_5413-4637                                
echo "adding host edge node_5413-4637"                                
sleep 0.2                                
funCreateV 'eth_5413_4637' 'eth_4637_5413' '31' '49' '10.1.184.1/24' '10.1.184.2/24'
# node_5413-15412                                
echo "adding host edge node_5413-15412"                                
sleep 0.2                                
funCreateV 'eth_5413_15412' 'eth_15412_5413' '31' '84' '10.1.185.1/24' '10.1.185.2/24'
# node_5413-702                                
echo "adding host edge node_5413-702"                                
sleep 0.2                                
funCreateV 'eth_5413_702' 'eth_702_5413' '31' '62' '10.1.186.1/24' '10.1.186.2/24'
# node_5413-4788                                
echo "adding host edge node_5413-4788"                                
sleep 0.2                                
funCreateV 'eth_5413_4788' 'eth_4788_5413' '31' '63' '10.1.188.1/24' '10.1.188.2/24'
# node_5413-13237                                
echo "adding cluster edge node_5413-13237"                                
sleep 0.2                                
funCreateClusterV 'eth_5413_13237' 'eth_13237_5413' '31' 'None' '10.1.189.1/24' '10.1.189.2/24'
# node_5413-15169                                
echo "adding host edge node_5413-15169"                                
sleep 0.2                                
funCreateV 'eth_5413_15169' 'eth_15169_5413' '31' '54' '10.1.193.1/24' '10.1.193.2/24'
# node_701-9318                                
echo "adding host edge node_701-9318"                                
sleep 0.2                                
funCreateV 'eth_701_9318' 'eth_9318_701' '32' '64' '10.3.154.2/24' '10.3.154.1/24'
# node_701-9929                                
echo "adding host edge node_701-9929"                                
sleep 0.2                                
funCreateV 'eth_701_9929' 'eth_9929_701' '32' '97' '10.3.167.1/24' '10.3.167.2/24'
# node_701-9680                                
echo "adding host edge node_701-9680"                                
sleep 0.2                                
funCreateV 'eth_701_9680' 'eth_9680_701' '32' '43' '10.3.168.1/24' '10.3.168.2/24'
# node_701-6830                                
echo "adding host edge node_701-6830"                                
sleep 0.2                                
funCreateV 'eth_701_6830' 'eth_6830_701' '32' '92' '10.2.210.2/24' '10.2.210.1/24'
# node_4134-58461                                
echo "adding cluster edge node_4134-58461"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_58461' 'eth_58461_4134' '33' 'None' '10.3.62.1/24' '10.3.62.2/24'
# node_4134-4657                                
echo "adding host edge node_4134-4657"                                
sleep 0.2                                
funCreateV 'eth_4134_4657' 'eth_4657_4134' '33' '57' '10.3.23.2/24' '10.3.23.1/24'
# node_4134-7497                                
echo "adding host edge node_4134-7497"                                
sleep 0.2                                
funCreateV 'eth_4134_7497' 'eth_7497_4134' '33' '96' '10.3.63.1/24' '10.3.63.2/24'
# node_4134-4811                                
echo "adding cluster edge node_4134-4811"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_4811' 'eth_4811_4134' '33' 'None' '10.3.64.1/24' '10.3.64.2/24'
# node_4134-6830                                
echo "adding host edge node_4134-6830"                                
sleep 0.2                                
funCreateV 'eth_4134_6830' 'eth_6830_4134' '33' '92' '10.2.206.2/24' '10.2.206.1/24'
# node_4134-11164                                
echo "adding cluster edge node_4134-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_11164' 'eth_11164_4134' '33' 'None' '10.2.160.2/24' '10.2.160.1/24'
# node_4134-2497                                
echo "adding host edge node_4134-2497"                                
sleep 0.2                                
funCreateV 'eth_4134_2497' 'eth_2497_4134' '33' '42' '10.1.153.2/24' '10.1.153.1/24'
# node_4134-58466                                
echo "adding cluster edge node_4134-58466"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_58466' 'eth_58466_4134' '33' 'None' '10.3.65.1/24' '10.3.65.2/24'
# node_4134-134756                                
echo "adding cluster edge node_4134-134756"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_134756' 'eth_134756_4134' '33' 'None' '10.3.66.1/24' '10.3.66.2/24'
# node_4134-38283                                
echo "adding cluster edge node_4134-38283"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_38283' 'eth_38283_4134' '33' 'None' '10.3.67.1/24' '10.3.67.2/24'
# node_4134-4847                                
echo "adding cluster edge node_4134-4847"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_4847' 'eth_4847_4134' '33' 'None' '10.3.68.1/24' '10.3.68.2/24'
# node_4134-23764                                
echo "adding host edge node_4134-23764"                                
sleep 0.2                                
funCreateV 'eth_4134_23764' 'eth_23764_4134' '33' '59' '10.3.69.1/24' '10.3.69.2/24'
# node_4134-140647                                
echo "adding cluster edge node_4134-140647"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_140647' 'eth_140647_4134' '33' 'None' '10.3.70.1/24' '10.3.70.2/24'
# node_4134-20764                                
echo "adding host edge node_4134-20764"                                
sleep 0.2                                
funCreateV 'eth_4134_20764' 'eth_20764_4134' '33' '93' '10.3.71.1/24' '10.3.71.2/24'
# node_4134-142404                                
echo "adding cluster edge node_4134-142404"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_142404' 'eth_142404_4134' '33' 'None' '10.3.72.1/24' '10.3.72.2/24'
# node_4134-132147                                
echo "adding cluster edge node_4134-132147"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_132147' 'eth_132147_4134' '33' 'None' '10.3.73.1/24' '10.3.73.2/24'
# node_4134-134768                                
echo "adding cluster edge node_4134-134768"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_134768' 'eth_134768_4134' '33' 'None' '10.3.74.1/24' '10.3.74.2/24'
# node_4134-23724                                
echo "adding cluster edge node_4134-23724"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_23724' 'eth_23724_4134' '33' 'None' '10.3.75.1/24' '10.3.75.2/24'
# node_4134-4812                                
echo "adding cluster edge node_4134-4812"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_4812' 'eth_4812_4134' '33' 'None' '10.3.76.1/24' '10.3.76.2/24'
# node_4134-9808                                
echo "adding cluster edge node_4134-9808"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_9808' 'eth_9808_4134' '33' 'None' '10.3.77.1/24' '10.3.77.2/24'
# node_4134-139019                                
echo "adding cluster edge node_4134-139019"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_139019' 'eth_139019_4134' '33' 'None' '10.3.78.1/24' '10.3.78.2/24'
# node_4134-137687                                
echo "adding cluster edge node_4134-137687"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_137687' 'eth_137687_4134' '33' 'None' '10.3.79.1/24' '10.3.79.2/24'
# node_4134-139018                                
echo "adding cluster edge node_4134-139018"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_139018' 'eth_139018_4134' '33' 'None' '10.3.80.1/24' '10.3.80.2/24'
# node_4134-4809                                
echo "adding host edge node_4134-4809"                                
sleep 0.2                                
funCreateV 'eth_4134_4809' 'eth_4809_4134' '33' '48' '10.3.81.1/24' '10.3.81.2/24'
# node_4134-139587                                
echo "adding cluster edge node_4134-139587"                                
sleep 0.2                                
funCreateClusterV 'eth_4134_139587' 'eth_139587_4134' '33' 'None' '10.3.82.1/24' '10.3.82.2/24'
# node_132203-18106                                
echo "adding host edge node_132203-18106"                                
sleep 0.2                                
funCreateV 'eth_132203_18106' 'eth_18106_132203' '34' '73' '10.0.187.2/24' '10.0.187.1/24'
# node_132203-12552                                
echo "adding host edge node_132203-12552"                                
sleep 0.2                                
funCreateV 'eth_132203_12552' 'eth_12552_132203' '34' '36' '10.2.121.2/24' '10.2.121.1/24'
# node_132203-20485                                
echo "adding host edge node_132203-20485"                                
sleep 0.2                                
funCreateV 'eth_132203_20485' 'eth_20485_132203' '34' '95' '10.3.29.2/24' '10.3.29.1/24'
# node_132203-23673                                
echo "adding host edge node_132203-23673"                                
sleep 0.2                                
funCreateV 'eth_132203_23673' 'eth_23673_132203' '34' '77' '10.1.249.2/24' '10.1.249.1/24'
# node_132203-4766                                
echo "adding host edge node_132203-4766"                                
sleep 0.2                                
funCreateV 'eth_132203_4766' 'eth_4766_132203' '34' '35' '10.3.0.2/24' '10.3.0.1/24'
# node_4766-4651                                
echo "adding host edge node_4766-4651"                                
sleep 0.2                                
funCreateV 'eth_4766_4651' 'eth_4651_4766' '35' '61' '10.2.238.2/24' '10.2.238.1/24'
# node_4766-131098                                
echo "adding cluster edge node_4766-131098"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_131098' 'eth_131098_4766' '35' 'None' '10.2.244.1/24' '10.2.244.2/24'
# node_4766-57304                                
echo "adding cluster edge node_4766-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_57304' 'eth_57304_4766' '35' 'None' '10.2.245.1/24' '10.2.245.2/24'
# node_4766-2497                                
echo "adding host edge node_4766-2497"                                
sleep 0.2                                
funCreateV 'eth_4766_2497' 'eth_2497_4766' '35' '42' '10.1.154.2/24' '10.1.154.1/24'
# node_4766-9957                                
echo "adding host edge node_4766-9957"                                
sleep 0.2                                
funCreateV 'eth_4766_9957' 'eth_9957_4766' '35' '56' '10.2.246.1/24' '10.2.246.2/24'
# node_4766-6830                                
echo "adding host edge node_4766-6830"                                
sleep 0.2                                
funCreateV 'eth_4766_6830' 'eth_6830_4766' '35' '92' '10.2.207.2/24' '10.2.207.1/24'
# node_4766-23599                                
echo "adding cluster edge node_4766-23599"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_23599' 'eth_23599_4766' '35' 'None' '10.2.247.1/24' '10.2.247.2/24'
# node_4766-1237                                
echo "adding host edge node_4766-1237"                                
sleep 0.2                                
funCreateV 'eth_4766_1237' 'eth_1237_4766' '35' '94' '10.2.248.1/24' '10.2.248.2/24'
# node_4766-23596                                
echo "adding cluster edge node_4766-23596"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_23596' 'eth_23596_4766' '35' 'None' '10.2.249.1/24' '10.2.249.2/24'
# node_4766-9858                                
echo "adding cluster edge node_4766-9858"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_9858' 'eth_9858_4766' '35' 'None' '10.2.250.1/24' '10.2.250.2/24'
# node_4766-23600                                
echo "adding cluster edge node_4766-23600"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_23600' 'eth_23600_4766' '35' 'None' '10.2.251.1/24' '10.2.251.2/24'
# node_4766-64050                                
echo "adding host edge node_4766-64050"                                
sleep 0.2                                
funCreateV 'eth_4766_64050' 'eth_64050_4766' '35' '87' '10.2.252.1/24' '10.2.252.2/24'
# node_4766-4775                                
echo "adding host edge node_4766-4775"                                
sleep 0.2                                
funCreateV 'eth_4766_4775' 'eth_4775_4766' '35' '44' '10.2.253.1/24' '10.2.253.2/24'
# node_4766-9318                                
echo "adding host edge node_4766-9318"                                
sleep 0.2                                
funCreateV 'eth_4766_9318' 'eth_9318_4766' '35' '64' '10.2.254.1/24' '10.2.254.2/24'
# node_4766-9286                                
echo "adding cluster edge node_4766-9286"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_9286' 'eth_9286_4766' '35' 'None' '10.2.255.1/24' '10.2.255.2/24'
# node_4766-9526                                
echo "adding cluster edge node_4766-9526"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_9526' 'eth_9526_4766' '35' 'None' '10.3.1.1/24' '10.3.1.2/24'
# node_4766-45376                                
echo "adding cluster edge node_4766-45376"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_45376' 'eth_45376_4766' '35' 'None' '10.3.2.1/24' '10.3.2.2/24'
# node_4766-55633                                
echo "adding cluster edge node_4766-55633"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_55633' 'eth_55633_4766' '35' 'None' '10.3.3.1/24' '10.3.3.2/24'
# node_4766-9684                                
echo "adding cluster edge node_4766-9684"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_9684' 'eth_9684_4766' '35' 'None' '10.3.4.1/24' '10.3.4.2/24'
# node_4766-7562                                
echo "adding cluster edge node_4766-7562"                                
sleep 0.2                                
funCreateClusterV 'eth_4766_7562' 'eth_7562_4766' '35' 'None' '10.3.5.1/24' '10.3.5.2/24'
# node_12552-49788                                
echo "adding host edge node_12552-49788"                                
sleep 0.2                                
funCreateV 'eth_12552_49788' 'eth_49788_12552' '36' '72' '10.0.156.2/24' '10.0.156.1/24'
# node_12552-4637                                
echo "adding host edge node_12552-4637"                                
sleep 0.2                                
funCreateV 'eth_12552_4637' 'eth_4637_12552' '36' '49' '10.2.114.1/24' '10.2.114.2/24'
# node_12552-9304                                
echo "adding host edge node_12552-9304"                                
sleep 0.2                                
funCreateV 'eth_12552_9304' 'eth_9304_12552' '36' '60' '10.2.115.1/24' '10.2.115.2/24'
# node_12552-702                                
echo "adding host edge node_12552-702"                                
sleep 0.2                                
funCreateV 'eth_12552_702' 'eth_702_12552' '36' '62' '10.2.116.1/24' '10.2.116.2/24'
# node_12552-3320                                
echo "adding host edge node_12552-3320"                                
sleep 0.2                                
funCreateV 'eth_12552_3320' 'eth_3320_12552' '36' '81' '10.2.117.1/24' '10.2.117.2/24'
# node_12552-9318                                
echo "adding host edge node_12552-9318"                                
sleep 0.2                                
funCreateV 'eth_12552_9318' 'eth_9318_12552' '36' '64' '10.2.120.1/24' '10.2.120.2/24'
# node_12552-8763                                
echo "adding host edge node_12552-8763"                                
sleep 0.2                                
funCreateV 'eth_12552_8763' 'eth_8763_12552' '36' '65' '10.2.122.1/24' '10.2.122.2/24'
# node_12552-9498                                
echo "adding host edge node_12552-9498"                                
sleep 0.2                                
funCreateV 'eth_12552_9498' 'eth_9498_12552' '36' '66' '10.2.123.1/24' '10.2.123.2/24'
# node_12552-3462                                
echo "adding host edge node_12552-3462"                                
sleep 0.2                                
funCreateV 'eth_12552_3462' 'eth_3462_12552' '36' '67' '10.2.125.1/24' '10.2.125.2/24'
# node_12552-23764                                
echo "adding host edge node_12552-23764"                                
sleep 0.2                                
funCreateV 'eth_12552_23764' 'eth_23764_12552' '36' '59' '10.2.126.1/24' '10.2.126.2/24'
# node_12552-18403                                
echo "adding host edge node_12552-18403"                                
sleep 0.2                                
funCreateV 'eth_12552_18403' 'eth_18403_12552' '36' '47' '10.2.127.1/24' '10.2.127.2/24'
# node_12552-58453                                
echo "adding host edge node_12552-58453"                                
sleep 0.2                                
funCreateV 'eth_12552_58453' 'eth_58453_12552' '36' '68' '10.2.128.1/24' '10.2.128.2/24'
# node_12552-9605                                
echo "adding host edge node_12552-9605"                                
sleep 0.2                                
funCreateV 'eth_12552_9605' 'eth_9605_12552' '36' '69' '10.2.129.1/24' '10.2.129.2/24'
# node_12552-6663                                
echo "adding host edge node_12552-6663"                                
sleep 0.2                                
funCreateV 'eth_12552_6663' 'eth_6663_12552' '36' '52' '10.2.130.1/24' '10.2.130.2/24'
# node_12552-15169                                
echo "adding host edge node_12552-15169"                                
sleep 0.2                                
funCreateV 'eth_12552_15169' 'eth_15169_12552' '36' '54' '10.2.131.1/24' '10.2.131.2/24'
# node_12552-9505                                
echo "adding host edge node_12552-9505"                                
sleep 0.2                                
funCreateV 'eth_12552_9505' 'eth_9505_12552' '36' '55' '10.2.133.1/24' '10.2.133.2/24'
# node_12552-10158                                
echo "adding host edge node_12552-10158"                                
sleep 0.2                                
funCreateV 'eth_12552_10158' 'eth_10158_12552' '36' '70' '10.2.134.1/24' '10.2.134.2/24'
# node_57866-6830                                
echo "adding host edge node_57866-6830"                                
sleep 0.2                                
funCreateV 'eth_57866_6830' 'eth_6830_57866' '37' '92' '10.0.222.1/24' '10.0.222.2/24'
# node_57866-15169                                
echo "adding host edge node_57866-15169"                                
sleep 0.2                                
funCreateV 'eth_57866_15169' 'eth_15169_57866' '37' '54' '10.0.226.1/24' '10.0.226.2/24'
# node_16735-22548                                
echo "adding cluster edge node_16735-22548"                                
sleep 0.2                                
funCreateClusterV 'eth_16735_22548' 'eth_22548_16735' '38' 'None' '10.3.190.2/24' '10.3.190.1/24'
# node_33891-5539                                
echo "adding cluster edge node_33891-5539"                                
sleep 0.2                                
funCreateClusterV 'eth_33891_5539' 'eth_5539_33891' '39' 'None' '10.3.197.1/24' '10.3.197.2/24'
# node_33891-18106                                
echo "adding host edge node_33891-18106"                                
sleep 0.2                                
funCreateV 'eth_33891_18106' 'eth_18106_33891' '39' '73' '10.0.189.2/24' '10.0.189.1/24'
# node_33891-22652                                
echo "adding host edge node_33891-22652"                                
sleep 0.2                                
funCreateV 'eth_33891_22652' 'eth_22652_33891' '39' '75' '10.0.218.2/24' '10.0.218.1/24'
# node_33891-23673                                
echo "adding host edge node_33891-23673"                                
sleep 0.2                                
funCreateV 'eth_33891_23673' 'eth_23673_33891' '39' '77' '10.1.250.2/24' '10.1.250.1/24'
# node_9607-59125                                
echo "adding cluster edge node_9607-59125"                                
sleep 0.2                                
funCreateClusterV 'eth_9607_59125' 'eth_59125_9607' '40' 'None' '10.3.199.2/24' '10.3.199.1/24'
# node_9607-4637                                
echo "adding host edge node_9607-4637"                                
sleep 0.2                                
funCreateV 'eth_9607_4637' 'eth_4637_9607' '40' '49' '10.2.138.2/24' '10.2.138.1/24'
# node_55410-21859                                
echo "adding cluster edge node_55410-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_21859' 'eth_21859_55410' '41' 'None' '10.3.41.2/24' '10.3.41.1/24'
# node_55410-9498                                
echo "adding host edge node_55410-9498"                                
sleep 0.2                                
funCreateV 'eth_55410_9498' 'eth_9498_55410' '41' '66' '10.3.176.1/24' '10.3.176.2/24'
# node_55410-45528                                
echo "adding cluster edge node_55410-45528"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_45528' 'eth_45528_55410' '41' 'None' '10.3.177.1/24' '10.3.177.2/24'
# node_55410-38266                                
echo "adding cluster edge node_55410-38266"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_38266' 'eth_38266_55410' '41' 'None' '10.3.178.1/24' '10.3.178.2/24'
# node_55410-4755                                
echo "adding cluster edge node_55410-4755"                                
sleep 0.2                                
funCreateClusterV 'eth_55410_4755' 'eth_4755_55410' '41' 'None' '10.3.107.2/24' '10.3.107.1/24'
# node_55410-55644                                
echo "adding host edge node_55410-55644"                                
sleep 0.2                                
funCreateV 'eth_55410_55644' 'eth_55644_55410' '41' '45' '10.3.179.1/24' '10.3.179.2/24'
# node_2497-11164                                
echo "adding cluster edge node_2497-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_11164' 'eth_11164_2497' '42' 'None' '10.1.138.1/24' '10.1.138.2/24'
# node_2497-3130                                
echo "adding cluster edge node_2497-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_3130' 'eth_3130_2497' '42' 'None' '10.1.139.1/24' '10.1.139.2/24'
# node_2497-9304                                
echo "adding host edge node_2497-9304"                                
sleep 0.2                                
funCreateV 'eth_2497_9304' 'eth_9304_2497' '42' '60' '10.1.141.1/24' '10.1.141.2/24'
# node_2497-7670                                
echo "adding host edge node_2497-7670"                                
sleep 0.2                                
funCreateV 'eth_2497_7670' 'eth_7670_2497' '42' '98' '10.1.142.1/24' '10.1.142.2/24'
# node_2497-6830                                
echo "adding host edge node_2497-6830"                                
sleep 0.2                                
funCreateV 'eth_2497_6830' 'eth_6830_2497' '42' '92' '10.1.143.1/24' '10.1.143.2/24'
# node_2497-17676                                
echo "adding host edge node_2497-17676"                                
sleep 0.2                                
funCreateV 'eth_2497_17676' 'eth_17676_2497' '42' '79' '10.1.148.1/24' '10.1.148.2/24'
# node_2497-7473                                
echo "adding host edge node_2497-7473"                                
sleep 0.2                                
funCreateV 'eth_2497_7473' 'eth_7473_2497' '42' '80' '10.1.149.1/24' '10.1.149.2/24'
# node_2497-4788                                
echo "adding host edge node_2497-4788"                                
sleep 0.2                                
funCreateV 'eth_2497_4788' 'eth_4788_2497' '42' '63' '10.1.150.1/24' '10.1.150.2/24'
# node_2497-9318                                
echo "adding host edge node_2497-9318"                                
sleep 0.2                                
funCreateV 'eth_2497_9318' 'eth_9318_2497' '42' '64' '10.1.152.1/24' '10.1.152.2/24'
# node_2497-4651                                
echo "adding host edge node_2497-4651"                                
sleep 0.2                                
funCreateV 'eth_2497_4651' 'eth_4651_2497' '42' '61' '10.1.156.1/24' '10.1.156.2/24'
# node_2497-59125                                
echo "adding cluster edge node_2497-59125"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_59125' 'eth_59125_2497' '42' 'None' '10.1.157.1/24' '10.1.157.2/24'
# node_2497-9498                                
echo "adding host edge node_2497-9498"                                
sleep 0.2                                
funCreateV 'eth_2497_9498' 'eth_9498_2497' '42' '66' '10.1.159.1/24' '10.1.159.2/24'
# node_2497-2514                                
echo "adding cluster edge node_2497-2514"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_2514' 'eth_2514_2497' '42' 'None' '10.1.160.1/24' '10.1.160.2/24'
# node_2497-3462                                
echo "adding host edge node_2497-3462"                                
sleep 0.2                                
funCreateV 'eth_2497_3462' 'eth_3462_2497' '42' '67' '10.1.161.1/24' '10.1.161.2/24'
# node_2497-4775                                
echo "adding host edge node_2497-4775"                                
sleep 0.2                                
funCreateV 'eth_2497_4775' 'eth_4775_2497' '42' '44' '10.1.162.1/24' '10.1.162.2/24'
# node_2497-16509                                
echo "adding host edge node_2497-16509"                                
sleep 0.2                                
funCreateV 'eth_2497_16509' 'eth_16509_2497' '42' '46' '10.1.164.1/24' '10.1.164.2/24'
# node_2497-9605                                
echo "adding host edge node_2497-9605"                                
sleep 0.2                                
funCreateV 'eth_2497_9605' 'eth_9605_2497' '42' '69' '10.1.165.1/24' '10.1.165.2/24'
# node_2497-18106                                
echo "adding host edge node_2497-18106"                                
sleep 0.2                                
funCreateV 'eth_2497_18106' 'eth_18106_2497' '42' '73' '10.0.200.2/24' '10.0.200.1/24'
# node_2497-3216                                
echo "adding cluster edge node_2497-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_2497_3216' 'eth_3216_2497' '42' 'None' '10.1.166.1/24' '10.1.166.2/24'
# node_2497-58453                                
echo "adding host edge node_2497-58453"                                
sleep 0.2                                
funCreateV 'eth_2497_58453' 'eth_58453_2497' '42' '68' '10.1.167.1/24' '10.1.167.2/24'
# node_2497-4637                                
echo "adding host edge node_2497-4637"                                
sleep 0.2                                
funCreateV 'eth_2497_4637' 'eth_4637_2497' '42' '49' '10.1.168.1/24' '10.1.168.2/24'
# node_2497-15169                                
echo "adding host edge node_2497-15169"                                
sleep 0.2                                
funCreateV 'eth_2497_15169' 'eth_15169_2497' '42' '54' '10.1.170.1/24' '10.1.170.2/24'
# node_9680-3462                                
echo "adding host edge node_9680-3462"                                
sleep 0.2                                
funCreateV 'eth_9680_3462' 'eth_3462_9680' '43' '67' '10.3.206.2/24' '10.3.206.1/24'
# node_4775-15412                                
echo "adding host edge node_4775-15412"                                
sleep 0.2                                
funCreateV 'eth_4775_15412' 'eth_15412_4775' '44' '84' '10.2.178.2/24' '10.2.178.1/24'
# node_4775-18106                                
echo "adding host edge node_4775-18106"                                
sleep 0.2                                
funCreateV 'eth_4775_18106' 'eth_18106_4775' '44' '73' '10.0.194.2/24' '10.0.194.1/24'
# node_4775-7473                                
echo "adding host edge node_4775-7473"                                
sleep 0.2                                
funCreateV 'eth_4775_7473' 'eth_7473_4775' '44' '80' '10.2.233.2/24' '10.2.233.1/24'
# node_4775-57304                                
echo "adding cluster edge node_4775-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_57304' 'eth_57304_4775' '44' 'None' '10.3.112.2/24' '10.3.112.1/24'
# node_4775-4637                                
echo "adding host edge node_4775-4637"                                
sleep 0.2                                
funCreateV 'eth_4775_4637' 'eth_4637_4775' '44' '49' '10.2.140.2/24' '10.2.140.1/24'
# node_4775-132199                                
echo "adding cluster edge node_4775-132199"                                
sleep 0.2                                
funCreateClusterV 'eth_4775_132199' 'eth_132199_4775' '44' 'None' '10.3.208.1/24' '10.3.208.2/24'
# node_55644-9498                                
echo "adding host edge node_55644-9498"                                
sleep 0.2                                
funCreateV 'eth_55644_9498' 'eth_9498_55644' '45' '66' '10.3.203.2/24' '10.3.203.1/24'
# node_55644-45271                                
echo "adding cluster edge node_55644-45271"                                
sleep 0.2                                
funCreateClusterV 'eth_55644_45271' 'eth_45271_55644' '45' 'None' '10.3.210.1/24' '10.3.210.2/24'
# node_55644-38266                                
echo "adding cluster edge node_55644-38266"                                
sleep 0.2                                
funCreateClusterV 'eth_55644_38266' 'eth_38266_55644' '45' 'None' '10.3.209.2/24' '10.3.209.1/24'
# node_16509-18106                                
echo "adding host edge node_16509-18106"                                
sleep 0.2                                
funCreateV 'eth_16509_18106' 'eth_18106_16509' '46' '73' '10.0.195.2/24' '10.0.195.1/24'
# node_16509-3320                                
echo "adding host edge node_16509-3320"                                
sleep 0.2                                
funCreateV 'eth_16509_3320' 'eth_3320_16509' '46' '81' '10.3.102.2/24' '10.3.102.1/24'
# node_16509-11686                                
echo "adding host edge node_16509-11686"                                
sleep 0.2                                
funCreateV 'eth_16509_11686' 'eth_11686_16509' '46' '74' '10.0.211.2/24' '10.0.211.1/24'
# node_16509-20485                                
echo "adding host edge node_16509-20485"                                
sleep 0.2                                
funCreateV 'eth_16509_20485' 'eth_20485_16509' '46' '95' '10.3.32.2/24' '10.3.32.1/24'
# node_16509-23673                                
echo "adding host edge node_16509-23673"                                
sleep 0.2                                
funCreateV 'eth_16509_23673' 'eth_23673_16509' '46' '77' '10.1.253.2/24' '10.1.253.1/24'
# node_16509-1221                                
echo "adding cluster edge node_16509-1221"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_1221' 'eth_1221_16509' '46' 'None' '10.3.213.1/24' '10.3.213.2/24'
# node_16509-11537                                
echo "adding cluster edge node_16509-11537"                                
sleep 0.2                                
funCreateClusterV 'eth_16509_11537' 'eth_11537_16509' '46' 'None' '10.3.130.2/24' '10.3.130.1/24'
# node_18403-18106                                
echo "adding host edge node_18403-18106"                                
sleep 0.2                                
funCreateV 'eth_18403_18106' 'eth_18106_18403' '47' '73' '10.0.199.2/24' '10.0.199.1/24'
# node_18403-23673                                
echo "adding host edge node_18403-23673"                                
sleep 0.2                                
funCreateV 'eth_18403_23673' 'eth_23673_18403' '47' '77' '10.1.254.2/24' '10.1.254.1/24'
# node_18403-4637                                
echo "adding host edge node_18403-4637"                                
sleep 0.2                                
funCreateV 'eth_18403_4637' 'eth_4637_18403' '47' '49' '10.2.142.2/24' '10.2.142.1/24'
# node_18403-58453                                
echo "adding host edge node_18403-58453"                                
sleep 0.2                                
funCreateV 'eth_18403_58453' 'eth_58453_18403' '47' '68' '10.2.225.2/24' '10.2.225.1/24'
# node_18403-7473                                
echo "adding host edge node_18403-7473"                                
sleep 0.2                                
funCreateV 'eth_18403_7473' 'eth_7473_18403' '47' '80' '10.2.237.2/24' '10.2.237.1/24'
# node_18403-12389                                
echo "adding cluster edge node_18403-12389"                                
sleep 0.2                                
funCreateClusterV 'eth_18403_12389' 'eth_12389_18403' '47' 'None' '10.3.222.1/24' '10.3.222.2/24'
# node_4809-3320                                
echo "adding host edge node_4809-3320"                                
sleep 0.2                                
funCreateV 'eth_4809_3320' 'eth_3320_4809' '48' '81' '10.3.103.2/24' '10.3.103.1/24'
# node_4809-18106                                
echo "adding host edge node_4809-18106"                                
sleep 0.2                                
funCreateV 'eth_4809_18106' 'eth_18106_4809' '48' '73' '10.0.202.2/24' '10.0.202.1/24'
# node_4809-9304                                
echo "adding host edge node_4809-9304"                                
sleep 0.2                                
funCreateV 'eth_4809_9304' 'eth_9304_4809' '48' '60' '10.2.166.2/24' '10.2.166.1/24'
# node_4809-23764                                
echo "adding host edge node_4809-23764"                                
sleep 0.2                                
funCreateV 'eth_4809_23764' 'eth_23764_4809' '48' '59' '10.3.95.2/24' '10.3.95.1/24'
# node_4637-7670                                
echo "adding host edge node_4637-7670"                                
sleep 0.2                                
funCreateV 'eth_4637_7670' 'eth_7670_4637' '49' '98' '10.2.136.1/24' '10.2.136.2/24'
# node_4637-11164                                
echo "adding cluster edge node_4637-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_11164' 'eth_11164_4637' '49' 'None' '10.2.137.1/24' '10.2.137.2/24'
# node_4637-9498                                
echo "adding host edge node_4637-9498"                                
sleep 0.2                                
funCreateV 'eth_4637_9498' 'eth_9498_4637' '49' '66' '10.2.139.1/24' '10.2.139.2/24'
# node_4637-1221                                
echo "adding cluster edge node_4637-1221"                                
sleep 0.2                                
funCreateClusterV 'eth_4637_1221' 'eth_1221_4637' '49' 'None' '10.2.141.1/24' '10.2.141.2/24'
# node_4637-4657                                
echo "adding host edge node_4637-4657"                                
sleep 0.2                                
funCreateV 'eth_4637_4657' 'eth_4657_4637' '49' '57' '10.2.143.1/24' '10.2.143.2/24'
# node_4637-6830                                
echo "adding host edge node_4637-6830"                                
sleep 0.2                                
funCreateV 'eth_4637_6830' 'eth_6830_4637' '49' '92' '10.2.144.1/24' '10.2.144.2/24'
# node_4637-4651                                
echo "adding host edge node_4637-4651"                                
sleep 0.2                                
funCreateV 'eth_4637_4651' 'eth_4651_4637' '49' '61' '10.2.145.1/24' '10.2.145.2/24'
# node_136907-7303                                
echo "adding host edge node_136907-7303"                                
sleep 0.2                                
funCreateV 'eth_136907_7303' 'eth_7303_136907' '50' '51' '10.3.231.1/24' '10.3.231.2/24'
# node_6663-12975                                
echo "adding cluster edge node_6663-12975"                                
sleep 0.2                                
funCreateClusterV 'eth_6663_12975' 'eth_12975_6663' '52' 'None' '10.3.232.2/24' '10.3.232.1/24'
# node_6663-18106                                
echo "adding host edge node_6663-18106"                                
sleep 0.2                                
funCreateV 'eth_6663_18106' 'eth_18106_6663' '52' '73' '10.0.204.2/24' '10.0.204.1/24'
# node_15169-396982                                
echo "adding cluster edge node_15169-396982"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_396982' 'eth_396982_15169' '54' 'None' '10.3.233.2/24' '10.3.233.1/24'
# node_15169-3130                                
echo "adding cluster edge node_15169-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_15169_3130' 'eth_3130_15169' '54' 'None' '10.2.13.2/24' '10.2.13.1/24'
# node_15169-20912                                
echo "adding host edge node_15169-20912"                                
sleep 0.2                                
funCreateV 'eth_15169_20912' 'eth_20912_15169' '54' '71' '10.0.124.2/24' '10.0.124.1/24'
# node_15169-18106                                
echo "adding host edge node_15169-18106"                                
sleep 0.2                                
funCreateV 'eth_15169_18106' 'eth_18106_15169' '54' '73' '10.0.205.2/24' '10.0.205.1/24'
# node_15169-11686                                
echo "adding host edge node_15169-11686"                                
sleep 0.2                                
funCreateV 'eth_15169_11686' 'eth_11686_15169' '54' '74' '10.0.212.2/24' '10.0.212.1/24'
# node_15169-22652                                
echo "adding host edge node_15169-22652"                                
sleep 0.2                                
funCreateV 'eth_15169_22652' 'eth_22652_15169' '54' '75' '10.0.219.2/24' '10.0.219.1/24'
# node_15169-8492                                
echo "adding host edge node_15169-8492"                                
sleep 0.2                                
funCreateV 'eth_15169_8492' 'eth_8492_15169' '54' '76' '10.0.235.2/24' '10.0.235.1/24'
# node_15169-23673                                
echo "adding host edge node_15169-23673"                                
sleep 0.2                                
funCreateV 'eth_15169_23673' 'eth_23673_15169' '54' '77' '10.1.255.2/24' '10.1.255.1/24'
# node_15169-1403                                
echo "adding host edge node_15169-1403"                                
sleep 0.2                                
funCreateV 'eth_15169_1403' 'eth_1403_15169' '54' '78' '10.2.8.2/24' '10.2.8.1/24'
# node_9505-24157                                
echo "adding cluster edge node_9505-24157"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_24157' 'eth_24157_9505' '55' 'None' '10.3.239.2/24' '10.3.239.1/24'
# node_9505-18106                                
echo "adding host edge node_9505-18106"                                
sleep 0.2                                
funCreateV 'eth_9505_18106' 'eth_18106_9505' '55' '73' '10.0.206.2/24' '10.0.206.1/24'
# node_9505-57304                                
echo "adding cluster edge node_9505-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_9505_57304' 'eth_57304_9505' '55' 'None' '10.3.113.2/24' '10.3.113.1/24'
# node_9505-23673                                
echo "adding host edge node_9505-23673"                                
sleep 0.2                                
funCreateV 'eth_9505_23673' 'eth_23673_9505' '55' '77' '10.2.1.2/24' '10.2.1.1/24'
# node_9957-23764                                
echo "adding host edge node_9957-23764"                                
sleep 0.2                                
funCreateV 'eth_9957_23764' 'eth_23764_9957' '56' '59' '10.3.91.2/24' '10.3.91.1/24'
# node_9957-38091                                
echo "adding cluster edge node_9957-38091"                                
sleep 0.2                                
funCreateClusterV 'eth_9957_38091' 'eth_38091_9957' '56' 'None' '10.3.149.2/24' '10.3.149.1/24'
# node_9957-9286                                
echo "adding cluster edge node_9957-9286"                                
sleep 0.2                                
funCreateClusterV 'eth_9957_9286' 'eth_9286_9957' '56' 'None' '10.3.169.1/24' '10.3.169.2/24'
# node_9957-58453                                
echo "adding host edge node_9957-58453"                                
sleep 0.2                                
funCreateV 'eth_9957_58453' 'eth_58453_9957' '56' '68' '10.2.228.2/24' '10.2.228.1/24'
# node_4657-18106                                
echo "adding host edge node_4657-18106"                                
sleep 0.2                                
funCreateV 'eth_4657_18106' 'eth_18106_4657' '57' '73' '10.0.179.2/24' '10.0.179.1/24'
# node_4657-3462                                
echo "adding host edge node_4657-3462"                                
sleep 0.2                                
funCreateV 'eth_4657_3462' 'eth_3462_4657' '57' '67' '10.3.25.1/24' '10.3.25.2/24'
# node_45974-9318                                
echo "adding host edge node_45974-9318"                                
sleep 0.2                                
funCreateV 'eth_45974_9318' 'eth_9318_45974' '58' '64' '10.3.164.2/24' '10.3.164.1/24'
# node_23764-23673                                
echo "adding host edge node_23764-23673"                                
sleep 0.2                                
funCreateV 'eth_23764_23673' 'eth_23673_23764' '59' '77' '10.1.246.2/24' '10.1.246.1/24'
# node_23764-9318                                
echo "adding host edge node_23764-9318"                                
sleep 0.2                                
funCreateV 'eth_23764_9318' 'eth_9318_23764' '59' '64' '10.3.92.1/24' '10.3.92.2/24'
# node_23764-3462                                
echo "adding host edge node_23764-3462"                                
sleep 0.2                                
funCreateV 'eth_23764_3462' 'eth_3462_23764' '59' '67' '10.3.93.1/24' '10.3.93.2/24'
# node_23764-7473                                
echo "adding host edge node_23764-7473"                                
sleep 0.2                                
funCreateV 'eth_23764_7473' 'eth_7473_23764' '59' '80' '10.2.235.2/24' '10.2.235.1/24'
# node_23764-4538                                
echo "adding host edge node_23764-4538"                                
sleep 0.2                                
funCreateV 'eth_23764_4538' 'eth_4538_23764' '59' '90' '10.3.94.1/24' '10.3.94.2/24'
# node_23764-18106                                
echo "adding host edge node_23764-18106"                                
sleep 0.2                                
funCreateV 'eth_23764_18106' 'eth_18106_23764' '59' '73' '10.0.198.2/24' '10.0.198.1/24'
# node_23764-9848                                
echo "adding cluster edge node_23764-9848"                                
sleep 0.2                                
funCreateClusterV 'eth_23764_9848' 'eth_9848_23764' '59' 'None' '10.3.96.1/24' '10.3.96.2/24'
# node_9304-141750                                
echo "adding cluster edge node_9304-141750"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_141750' 'eth_141750_9304' '60' 'None' '10.2.162.1/24' '10.2.162.2/24'
# node_9304-15412                                
echo "adding host edge node_9304-15412"                                
sleep 0.2                                
funCreateV 'eth_9304_15412' 'eth_15412_9304' '60' '84' '10.2.164.1/24' '10.2.164.2/24'
# node_9304-3216                                
echo "adding cluster edge node_9304-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_3216' 'eth_3216_9304' '60' 'None' '10.2.165.1/24' '10.2.165.2/24'
# node_9304-55329                                
echo "adding cluster edge node_9304-55329"                                
sleep 0.2                                
funCreateClusterV 'eth_9304_55329' 'eth_55329_9304' '60' 'None' '10.2.167.1/24' '10.2.167.2/24'
# node_9304-9318                                
echo "adding host edge node_9304-9318"                                
sleep 0.2                                
funCreateV 'eth_9304_9318' 'eth_9318_9304' '60' '64' '10.2.168.1/24' '10.2.168.2/24'
# node_4651-23969                                
echo "adding cluster edge node_4651-23969"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_23969' 'eth_23969_4651' '61' 'None' '10.2.214.2/24' '10.2.214.1/24'
# node_4651-18106                                
echo "adding host edge node_4651-18106"                                
sleep 0.2                                
funCreateV 'eth_4651_18106' 'eth_18106_4651' '61' '73' '10.0.190.2/24' '10.0.190.1/24'
# node_4651-131293                                
echo "adding cluster edge node_4651-131293"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_131293' 'eth_131293_4651' '61' 'None' '10.2.242.1/24' '10.2.242.2/24'
# node_4651-4621                                
echo "adding cluster edge node_4651-4621"                                
sleep 0.2                                
funCreateClusterV 'eth_4651_4621' 'eth_4621_4651' '61' 'None' '10.2.243.1/24' '10.2.243.2/24'
# node_4788-134809                                
echo "adding cluster edge node_4788-134809"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_134809' 'eth_134809_4788' '63' 'None' '10.3.120.1/24' '10.3.120.2/24'
# node_4788-11164                                
echo "adding cluster edge node_4788-11164"                                
sleep 0.2                                
funCreateClusterV 'eth_4788_11164' 'eth_11164_4788' '63' 'None' '10.2.159.2/24' '10.2.159.1/24'
# node_4788-15932                                
echo "adding host edge node_4788-15932"                                
sleep 0.2                                
funCreateV 'eth_4788_15932' 'eth_15932_4788' '63' '89' '10.3.121.1/24' '10.3.121.2/24'
# node_9318-45996                                
echo "adding cluster edge node_9318-45996"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_45996' 'eth_45996_9318' '64' 'None' '10.3.153.2/24' '10.3.153.1/24'
# node_9318-3130                                
echo "adding cluster edge node_9318-3130"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_3130' 'eth_3130_9318' '64' 'None' '10.2.10.2/24' '10.2.10.1/24'
# node_9318-18106                                
echo "adding host edge node_9318-18106"                                
sleep 0.2                                
funCreateV 'eth_9318_18106' 'eth_18106_9318' '64' '73' '10.0.186.2/24' '10.0.186.1/24'
# node_9318-20764                                
echo "adding host edge node_9318-20764"                                
sleep 0.2                                
funCreateV 'eth_9318_20764' 'eth_20764_9318' '64' '93' '10.3.118.2/24' '10.3.118.1/24'
# node_9318-131100                                
echo "adding cluster edge node_9318-131100"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_131100' 'eth_131100_9318' '64' 'None' '10.3.155.1/24' '10.3.155.2/24'
# node_9318-23599                                
echo "adding cluster edge node_9318-23599"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_23599' 'eth_23599_9318' '64' 'None' '10.3.156.1/24' '10.3.156.2/24'
# node_9318-9858                                
echo "adding cluster edge node_9318-9858"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9858' 'eth_9858_9318' '64' 'None' '10.3.157.1/24' '10.3.157.2/24'
# node_9318-23600                                
echo "adding cluster edge node_9318-23600"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_23600' 'eth_23600_9318' '64' 'None' '10.3.158.1/24' '10.3.158.2/24'
# node_9318-38091                                
echo "adding cluster edge node_9318-38091"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_38091' 'eth_38091_9318' '64' 'None' '10.3.152.2/24' '10.3.152.1/24'
# node_9318-23588                                
echo "adding cluster edge node_9318-23588"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_23588' 'eth_23588_9318' '64' 'None' '10.3.159.1/24' '10.3.159.2/24'
# node_9318-3216                                
echo "adding cluster edge node_9318-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_3216' 'eth_3216_9318' '64' 'None' '10.2.200.2/24' '10.2.200.1/24'
# node_9318-9286                                
echo "adding cluster edge node_9318-9286"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9286' 'eth_9286_9318' '64' 'None' '10.3.160.1/24' '10.3.160.2/24'
# node_9318-9579                                
echo "adding cluster edge node_9318-9579"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9579' 'eth_9579_9318' '64' 'None' '10.3.161.1/24' '10.3.161.2/24'
# node_9318-9526                                
echo "adding cluster edge node_9318-9526"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9526' 'eth_9526_9318' '64' 'None' '10.3.162.1/24' '10.3.162.2/24'
# node_9318-18305                                
echo "adding cluster edge node_9318-18305"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_18305' 'eth_18305_9318' '64' 'None' '10.3.163.1/24' '10.3.163.2/24'
# node_9318-9630                                
echo "adding cluster edge node_9318-9630"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9630' 'eth_9630_9318' '64' 'None' '10.3.165.1/24' '10.3.165.2/24'
# node_9318-9638                                
echo "adding cluster edge node_9318-9638"                                
sleep 0.2                                
funCreateClusterV 'eth_9318_9638' 'eth_9638_9318' '64' 'None' '10.3.166.1/24' '10.3.166.2/24'
# node_8763-13237                                
echo "adding cluster edge node_8763-13237"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_13237' 'eth_13237_8763' '65' 'None' '10.3.193.2/24' '10.3.193.1/24'
# node_8763-23600                                
echo "adding cluster edge node_8763-23600"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_23600' 'eth_23600_8763' '65' 'None' '10.3.192.2/24' '10.3.192.1/24'
# node_8763-24785                                
echo "adding host edge node_8763-24785"                                
sleep 0.2                                
funCreateV 'eth_8763_24785' 'eth_24785_8763' '65' '86' '10.3.194.1/24' '10.3.194.2/24'
# node_8763-5539                                
echo "adding cluster edge node_8763-5539"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_5539' 'eth_5539_8763' '65' 'None' '10.3.195.1/24' '10.3.195.2/24'
# node_8763-20562                                
echo "adding cluster edge node_8763-20562"                                
sleep 0.2                                
funCreateClusterV 'eth_8763_20562' 'eth_20562_8763' '65' 'None' '10.3.196.1/24' '10.3.196.2/24'
# node_9498-18106                                
echo "adding host edge node_9498-18106"                                
sleep 0.2                                
funCreateV 'eth_9498_18106' 'eth_18106_9498' '66' '73' '10.0.191.2/24' '10.0.191.1/24'
# node_9498-23673                                
echo "adding host edge node_9498-23673"                                
sleep 0.2                                
funCreateV 'eth_9498_23673' 'eth_23673_9498' '66' '77' '10.1.251.2/24' '10.1.251.1/24'
# node_9498-45528                                
echo "adding cluster edge node_9498-45528"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_45528' 'eth_45528_9498' '66' 'None' '10.3.200.2/24' '10.3.200.1/24'
# node_9498-9730                                
echo "adding cluster edge node_9498-9730"                                
sleep 0.2                                
funCreateClusterV 'eth_9498_9730' 'eth_9730_9498' '66' 'None' '10.3.202.1/24' '10.3.202.2/24'
# node_3462-3216                                
echo "adding cluster edge node_3462-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_3462_3216' 'eth_3216_3462' '67' 'None' '10.2.198.2/24' '10.2.198.1/24'
# node_58453-4538                                
echo "adding host edge node_58453-4538"                                
sleep 0.2                                
funCreateV 'eth_58453_4538' 'eth_4538_58453' '68' '90' '10.2.224.1/24' '10.2.224.2/24'
# node_58453-9808                                
echo "adding cluster edge node_58453-9808"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_9808' 'eth_9808_58453' '68' 'None' '10.2.226.1/24' '10.2.226.2/24'
# node_58453-24157                                
echo "adding cluster edge node_58453-24157"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_24157' 'eth_24157_58453' '68' 'None' '10.2.227.1/24' '10.2.227.2/24'
# node_58453-23673                                
echo "adding host edge node_58453-23673"                                
sleep 0.2                                
funCreateV 'eth_58453_23673' 'eth_23673_58453' '68' '77' '10.2.2.2/24' '10.2.2.1/24'
# node_58453-9848                                
echo "adding cluster edge node_58453-9848"                                
sleep 0.2                                
funCreateClusterV 'eth_58453_9848' 'eth_9848_58453' '68' 'None' '10.2.229.1/24' '10.2.229.2/24'
# node_9605-3216                                
echo "adding cluster edge node_9605-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_3216' 'eth_3216_9605' '69' 'None' '10.2.199.2/24' '10.2.199.1/24'
# node_9605-2514                                
echo "adding cluster edge node_9605-2514"                                
sleep 0.2                                
funCreateClusterV 'eth_9605_2514' 'eth_2514_9605' '69' 'None' '10.3.205.2/24' '10.3.205.1/24'
# node_9605-18106                                
echo "adding host edge node_9605-18106"                                
sleep 0.2                                
funCreateV 'eth_9605_18106' 'eth_18106_9605' '69' '73' '10.0.201.2/24' '10.0.201.1/24'
# node_9605-20485                                
echo "adding host edge node_9605-20485"                                
sleep 0.2                                
funCreateV 'eth_9605_20485' 'eth_20485_9605' '69' '95' '10.3.33.2/24' '10.3.33.1/24'
# node_10158-38099                                
echo "adding cluster edge node_10158-38099"                                
sleep 0.2                                
funCreateClusterV 'eth_10158_38099' 'eth_38099_10158' '70' 'None' '10.3.241.2/24' '10.3.241.1/24'
# node_10158-15412                                
echo "adding host edge node_10158-15412"                                
sleep 0.2                                
funCreateV 'eth_10158_15412' 'eth_15412_10158' '70' '84' '10.2.181.2/24' '10.2.181.1/24'
# node_10158-18106                                
echo "adding host edge node_10158-18106"                                
sleep 0.2                                
funCreateV 'eth_10158_18106' 'eth_18106_10158' '70' '73' '10.0.207.2/24' '10.0.207.1/24'
# node_10158-23673                                
echo "adding host edge node_10158-23673"                                
sleep 0.2                                
funCreateV 'eth_10158_23673' 'eth_23673_10158' '70' '77' '10.2.3.2/24' '10.2.3.1/24'
# node_20912-49367                                
echo "adding cluster edge node_20912-49367"                                
sleep 0.2                                
funCreateClusterV 'eth_20912_49367' 'eth_49367_20912' '71' 'None' '10.0.123.1/24' '10.0.123.2/24'
# node_18106-15412                                
echo "adding host edge node_18106-15412"                                
sleep 0.2                                
funCreateV 'eth_18106_15412' 'eth_15412_18106' '73' '84' '10.0.177.1/24' '10.0.177.2/24'
# node_18106-21859                                
echo "adding cluster edge node_18106-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_21859' 'eth_21859_18106' '73' 'None' '10.0.180.1/24' '10.0.180.2/24'
# node_18106-17676                                
echo "adding host edge node_18106-17676"                                
sleep 0.2                                
funCreateV 'eth_18106_17676' 'eth_17676_18106' '73' '79' '10.0.181.1/24' '10.0.181.2/24'
# node_18106-9583                                
echo "adding host edge node_18106-9583"                                
sleep 0.2                                
funCreateV 'eth_18106_9583' 'eth_9583_18106' '73' '85' '10.0.182.1/24' '10.0.182.2/24'
# node_18106-134809                                
echo "adding cluster edge node_18106-134809"                                
sleep 0.2                                
funCreateClusterV 'eth_18106_134809' 'eth_134809_18106' '73' 'None' '10.0.185.1/24' '10.0.185.2/24'
# node_18106-64050                                
echo "adding host edge node_18106-64050"                                
sleep 0.2                                
funCreateV 'eth_18106_64050' 'eth_64050_18106' '73' '87' '10.0.192.1/24' '10.0.192.2/24'
# node_18106-15932                                
echo "adding host edge node_18106-15932"                                
sleep 0.2                                
funCreateV 'eth_18106_15932' 'eth_15932_18106' '73' '89' '10.0.196.1/24' '10.0.196.2/24'
# node_18106-10089                                
echo "adding host edge node_18106-10089"                                
sleep 0.2                                
funCreateV 'eth_18106_10089' 'eth_10089_18106' '73' '88' '10.0.197.1/24' '10.0.197.2/24'
# node_18106-4826                                
echo "adding host edge node_18106-4826"                                
sleep 0.2                                
funCreateV 'eth_18106_4826' 'eth_4826_18106' '73' '91' '10.0.203.1/24' '10.0.203.2/24'
# node_8492-3216                                
echo "adding cluster edge node_8492-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_3216' 'eth_3216_8492' '76' 'None' '10.0.229.1/24' '10.0.229.2/24'
# node_8492-20485                                
echo "adding host edge node_8492-20485"                                
sleep 0.2                                
funCreateV 'eth_8492_20485' 'eth_20485_8492' '76' '95' '10.0.231.1/24' '10.0.231.2/24'
# node_8492-57304                                
echo "adding cluster edge node_8492-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_57304' 'eth_57304_8492' '76' 'None' '10.0.232.1/24' '10.0.232.2/24'
# node_8492-20764                                
echo "adding host edge node_8492-20764"                                
sleep 0.2                                
funCreateV 'eth_8492_20764' 'eth_20764_8492' '76' '93' '10.0.233.1/24' '10.0.233.2/24'
# node_8492-12389                                
echo "adding cluster edge node_8492-12389"                                
sleep 0.2                                
funCreateClusterV 'eth_8492_12389' 'eth_12389_8492' '76' 'None' '10.0.234.1/24' '10.0.234.2/24'
# node_23673-21859                                
echo "adding cluster edge node_23673-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_21859' 'eth_21859_23673' '77' 'None' '10.1.245.1/24' '10.1.245.2/24'
# node_23673-9583                                
echo "adding host edge node_23673-9583"                                
sleep 0.2                                
funCreateV 'eth_23673_9583' 'eth_9583_23673' '77' '85' '10.1.247.1/24' '10.1.247.2/24'
# node_23673-64050                                
echo "adding host edge node_23673-64050"                                
sleep 0.2                                
funCreateV 'eth_23673_64050' 'eth_64050_23673' '77' '87' '10.1.252.1/24' '10.1.252.2/24'
# node_23673-134089                                
echo "adding cluster edge node_23673-134089"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_134089' 'eth_134089_23673' '77' 'None' '10.2.0.1/24' '10.2.0.2/24'
# node_23673-55329                                
echo "adding cluster edge node_23673-55329"                                
sleep 0.2                                
funCreateClusterV 'eth_23673_55329' 'eth_55329_23673' '77' 'None' '10.2.4.1/24' '10.2.4.2/24'
# node_17676-4725                                
echo "adding cluster edge node_17676-4725"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_4725' 'eth_4725_17676' '79' 'None' '10.3.88.2/24' '10.3.88.1/24'
# node_17676-20485                                
echo "adding host edge node_17676-20485"                                
sleep 0.2                                
funCreateV 'eth_17676_20485' 'eth_20485_17676' '79' '95' '10.3.27.2/24' '10.3.27.1/24'
# node_17676-59125                                
echo "adding cluster edge node_17676-59125"                                
sleep 0.2                                
funCreateClusterV 'eth_17676_59125' 'eth_59125_17676' '79' 'None' '10.3.89.1/24' '10.3.89.2/24'
# node_17676-64050                                
echo "adding host edge node_17676-64050"                                
sleep 0.2                                
funCreateV 'eth_17676_64050' 'eth_64050_17676' '79' '87' '10.3.90.1/24' '10.3.90.2/24'
# node_7473-9583                                
echo "adding host edge node_7473-9583"                                
sleep 0.2                                
funCreateV 'eth_7473_9583' 'eth_9583_7473' '80' '85' '10.2.230.1/24' '10.2.230.2/24'
# node_7473-64050                                
echo "adding host edge node_7473-64050"                                
sleep 0.2                                
funCreateV 'eth_7473_64050' 'eth_64050_7473' '80' '87' '10.2.232.1/24' '10.2.232.2/24'
# node_7473-4804                                
echo "adding cluster edge node_7473-4804"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_4804' 'eth_4804_7473' '80' 'None' '10.2.234.1/24' '10.2.234.2/24'
# node_7473-7474                                
echo "adding cluster edge node_7473-7474"                                
sleep 0.2                                
funCreateClusterV 'eth_7473_7474' 'eth_7474_7473' '80' 'None' '10.2.236.1/24' '10.2.236.2/24'
# node_3320-9583                                
echo "adding host edge node_3320-9583"                                
sleep 0.2                                
funCreateV 'eth_3320_9583' 'eth_9583_3320' '81' '85' '10.3.97.2/24' '10.3.97.1/24'
# node_7545-2764                                
echo "adding cluster edge node_7545-2764"                                
sleep 0.2                                
funCreateClusterV 'eth_7545_2764' 'eth_2764_7545' '83' 'None' '10.2.53.1/24' '10.2.53.2/24'
# node_15412-4804                                
echo "adding cluster edge node_15412-4804"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_4804' 'eth_4804_15412' '84' 'None' '10.2.179.1/24' '10.2.179.2/24'
# node_15412-24157                                
echo "adding cluster edge node_15412-24157"                                
sleep 0.2                                
funCreateClusterV 'eth_15412_24157' 'eth_24157_15412' '84' 'None' '10.2.180.1/24' '10.2.180.2/24'
# node_9583-4755                                
echo "adding cluster edge node_9583-4755"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_4755' 'eth_4755_9583' '85' 'None' '10.3.98.1/24' '10.3.98.2/24'
# node_9583-137130                                
echo "adding cluster edge node_9583-137130"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_137130' 'eth_137130_9583' '85' 'None' '10.3.99.1/24' '10.3.99.2/24'
# node_9583-140202                                
echo "adding cluster edge node_9583-140202"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_140202' 'eth_140202_9583' '85' 'None' '10.3.100.1/24' '10.3.100.2/24'
# node_9583-396421                                
echo "adding cluster edge node_9583-396421"                                
sleep 0.2                                
funCreateClusterV 'eth_9583_396421' 'eth_396421_9583' '85' 'None' '10.3.101.1/24' '10.3.101.2/24'
# node_24785-6830                                
echo "adding host edge node_24785-6830"                                
sleep 0.2                                
funCreateV 'eth_24785_6830' 'eth_6830_24785' '86' '92' '10.2.208.2/24' '10.2.208.1/24'
# node_64050-57304                                
echo "adding cluster edge node_64050-57304"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_57304' 'eth_57304_64050' '87' 'None' '10.3.111.2/24' '10.3.111.1/24'
# node_64050-3216                                
echo "adding cluster edge node_64050-3216"                                
sleep 0.2                                
funCreateClusterV 'eth_64050_3216' 'eth_3216_64050' '87' 'None' '10.2.197.2/24' '10.2.197.1/24'
# node_64050-20485                                
echo "adding host edge node_64050-20485"                                
sleep 0.2                                
funCreateV 'eth_64050_20485' 'eth_20485_64050' '87' '95' '10.3.31.2/24' '10.3.31.1/24'
# node_10089-9587                                
echo "adding cluster edge node_10089-9587"                                
sleep 0.2                                
funCreateClusterV 'eth_10089_9587' 'eth_9587_10089' '88' 'None' '10.3.215.1/24' '10.3.215.2/24'
# node_15932-9587                                
echo "adding cluster edge node_15932-9587"                                
sleep 0.2                                
funCreateClusterV 'eth_15932_9587' 'eth_9587_15932' '89' 'None' '10.3.216.2/24' '10.3.216.1/24'
# node_4538-23911                                
echo "adding cluster edge node_4538-23911"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_23911' 'eth_23911_4538' '90' 'None' '10.3.217.1/24' '10.3.217.2/24'
# node_4538-24361                                
echo "adding cluster edge node_4538-24361"                                
sleep 0.2                                
funCreateClusterV 'eth_4538_24361' 'eth_24361_4538' '90' 'None' '10.3.218.1/24' '10.3.218.2/24'
# node_4826-9723                                
echo "adding cluster edge node_4826-9723"                                
sleep 0.2                                
funCreateClusterV 'eth_4826_9723' 'eth_9723_4826' '91' 'None' '10.3.230.2/24' '10.3.230.1/24'
# node_1237-23596                                
echo "adding cluster edge node_1237-23596"                                
sleep 0.2                                
funCreateClusterV 'eth_1237_23596' 'eth_23596_1237' '94' 'None' '10.3.182.2/24' '10.3.182.1/24'
# node_20485-21859                                
echo "adding cluster edge node_20485-21859"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_21859' 'eth_21859_20485' '95' 'None' '10.3.26.1/24' '10.3.26.2/24'
# node_20485-59125                                
echo "adding cluster edge node_20485-59125"                                
sleep 0.2                                
funCreateClusterV 'eth_20485_59125' 'eth_59125_20485' '95' 'None' '10.3.30.1/24' '10.3.30.2/24'
# node_23352-20130                                
echo "adding cluster edge node_23352-20130"                                
sleep 0.2                                
funCreateClusterV 'eth_23352_20130' 'eth_20130_23352' '99' 'None' '10.1.74.2/24' '10.1.74.1/24'