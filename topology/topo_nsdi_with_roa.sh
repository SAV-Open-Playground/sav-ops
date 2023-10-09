#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("3356" "34224" "3549" "13335" "3303" "209" "1299" "174" "7018" "2519" "3257" "3741" "2914" "6762" "2516" "38040" "2152" "5511" "293" "4837" "1273" "1239" "6453" "31133" "64049" "6461" "3491" "6939" "9002" "37100" "3786" "5413" "701" "4134" "132203" "4766" "12552" "57866" "16735" "33891" "9607" "55410" "2497" "9680" "4775" "55644" "16509" "18403" "4809" "4637" )
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
# node_3356-34224                        
echo "adding edge node_3356-34224"                        
sleep 1                        
funCreateV 'eth_34224' 'eth_3356' '0' '1' '10.0.0.1/24' '10.0.0.2/24'
# node_3356-3549                        
echo "adding edge node_3356-3549"                        
sleep 1                        
funCreateV 'eth_3549' 'eth_3356' '0' '2' '10.0.1.1/24' '10.0.1.2/24'
# node_3356-13335                        
echo "adding edge node_3356-13335"                        
sleep 1                        
funCreateV 'eth_13335' 'eth_3356' '0' '3' '10.0.2.1/24' '10.0.2.2/24'
# node_3356-3303                        
echo "adding edge node_3356-3303"                        
sleep 1                        
funCreateV 'eth_3303' 'eth_3356' '0' '4' '10.0.3.1/24' '10.0.3.2/24'
# node_3356-209                        
echo "adding edge node_3356-209"                        
sleep 1                        
funCreateV 'eth_209' 'eth_3356' '0' '5' '10.0.4.1/24' '10.0.4.2/24'
# node_3356-1299                        
echo "adding edge node_3356-1299"                        
sleep 1                        
funCreateV 'eth_1299' 'eth_3356' '0' '6' '10.0.5.1/24' '10.0.5.2/24'
# node_3356-174                        
echo "adding edge node_3356-174"                        
sleep 1                        
funCreateV 'eth_174' 'eth_3356' '0' '7' '10.0.6.1/24' '10.0.6.2/24'
# node_3356-7018                        
echo "adding edge node_3356-7018"                        
sleep 1                        
funCreateV 'eth_7018' 'eth_3356' '0' '8' '10.0.7.1/24' '10.0.7.2/24'
# node_3356-2519                        
echo "adding edge node_3356-2519"                        
sleep 1                        
funCreateV 'eth_2519' 'eth_3356' '0' '9' '10.0.8.1/24' '10.0.8.2/24'
# node_3356-3257                        
echo "adding edge node_3356-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_3356' '0' '10' '10.0.9.1/24' '10.0.9.2/24'
# node_3356-3741                        
echo "adding edge node_3356-3741"                        
sleep 1                        
funCreateV 'eth_3741' 'eth_3356' '0' '11' '10.0.10.1/24' '10.0.10.2/24'
# node_3356-2914                        
echo "adding edge node_3356-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_3356' '0' '12' '10.0.11.1/24' '10.0.11.2/24'
# node_3356-6762                        
echo "adding edge node_3356-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_3356' '0' '13' '10.0.12.1/24' '10.0.12.2/24'
# node_3356-2516                        
echo "adding edge node_3356-2516"                        
sleep 1                        
funCreateV 'eth_2516' 'eth_3356' '0' '14' '10.0.13.1/24' '10.0.13.2/24'
# node_3356-38040                        
echo "adding edge node_3356-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_3356' '0' '15' '10.0.14.1/24' '10.0.14.2/24'
# node_3356-2152                        
echo "adding edge node_3356-2152"                        
sleep 1                        
funCreateV 'eth_2152' 'eth_3356' '0' '16' '10.0.15.1/24' '10.0.15.2/24'
# node_3356-5511                        
echo "adding edge node_3356-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_3356' '0' '17' '10.0.16.1/24' '10.0.16.2/24'
# node_3356-293                        
echo "adding edge node_3356-293"                        
sleep 1                        
funCreateV 'eth_293' 'eth_3356' '0' '18' '10.0.17.1/24' '10.0.17.2/24'
# node_3356-4837                        
echo "adding edge node_3356-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_3356' '0' '19' '10.0.18.1/24' '10.0.18.2/24'
# node_3356-1273                        
echo "adding edge node_3356-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_3356' '0' '20' '10.0.19.1/24' '10.0.19.2/24'
# node_3356-1239                        
echo "adding edge node_3356-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_3356' '0' '21' '10.0.20.1/24' '10.0.20.2/24'
# node_3356-6453                        
echo "adding edge node_3356-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_3356' '0' '22' '10.0.21.1/24' '10.0.21.2/24'
# node_3356-31133                        
echo "adding edge node_3356-31133"                        
sleep 1                        
funCreateV 'eth_31133' 'eth_3356' '0' '23' '10.0.22.1/24' '10.0.22.2/24'
# node_3356-64049                        
echo "adding edge node_3356-64049"                        
sleep 1                        
funCreateV 'eth_64049' 'eth_3356' '0' '24' '10.0.23.1/24' '10.0.23.2/24'
# node_3356-6461                        
echo "adding edge node_3356-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_3356' '0' '25' '10.0.24.1/24' '10.0.24.2/24'
# node_3356-3491                        
echo "adding edge node_3356-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_3356' '0' '26' '10.0.25.1/24' '10.0.25.2/24'
# node_3356-6939                        
echo "adding edge node_3356-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_3356' '0' '27' '10.0.26.1/24' '10.0.26.2/24'
# node_3356-9002                        
echo "adding edge node_3356-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_3356' '0' '28' '10.0.27.1/24' '10.0.27.2/24'
# node_3356-37100                        
echo "adding edge node_3356-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_3356' '0' '29' '10.0.28.1/24' '10.0.28.2/24'
# node_3356-3786                        
echo "adding edge node_3356-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_3356' '0' '30' '10.0.29.1/24' '10.0.29.2/24'
# node_3356-5413                        
echo "adding edge node_3356-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_3356' '0' '31' '10.0.30.1/24' '10.0.30.2/24'
# node_3356-701                        
echo "adding edge node_3356-701"                        
sleep 1                        
funCreateV 'eth_701' 'eth_3356' '0' '32' '10.0.31.1/24' '10.0.31.2/24'
# node_3356-4134                        
echo "adding edge node_3356-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_3356' '0' '33' '10.0.32.1/24' '10.0.32.2/24'
# node_3356-132203                        
echo "adding edge node_3356-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_3356' '0' '34' '10.0.33.1/24' '10.0.33.2/24'
# node_3356-4766                        
echo "adding edge node_3356-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_3356' '0' '35' '10.0.34.1/24' '10.0.34.2/24'
# node_3356-12552                        
echo "adding edge node_3356-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_3356' '0' '36' '10.0.35.1/24' '10.0.35.2/24'
# node_3356-57866                        
echo "adding edge node_3356-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_3356' '0' '37' '10.0.36.1/24' '10.0.36.2/24'
# node_3356-16735                        
echo "adding edge node_3356-16735"                        
sleep 1                        
funCreateV 'eth_16735' 'eth_3356' '0' '38' '10.0.37.1/24' '10.0.37.2/24'
# node_3356-33891                        
echo "adding edge node_3356-33891"                        
sleep 1                        
funCreateV 'eth_33891' 'eth_3356' '0' '39' '10.0.38.1/24' '10.0.38.2/24'
# node_3356-9607                        
echo "adding edge node_3356-9607"                        
sleep 1                        
funCreateV 'eth_9607' 'eth_3356' '0' '40' '10.0.39.1/24' '10.0.39.2/24'
# node_3356-55410                        
echo "adding edge node_3356-55410"                        
sleep 1                        
funCreateV 'eth_55410' 'eth_3356' '0' '41' '10.0.40.1/24' '10.0.40.2/24'
# node_3356-2497                        
echo "adding edge node_3356-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_3356' '0' '42' '10.0.41.1/24' '10.0.41.2/24'
# node_3356-9680                        
echo "adding edge node_3356-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_3356' '0' '43' '10.0.42.1/24' '10.0.42.2/24'
# node_3356-4775                        
echo "adding edge node_3356-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_3356' '0' '44' '10.0.43.1/24' '10.0.43.2/24'
# node_3356-55644                        
echo "adding edge node_3356-55644"                        
sleep 1                        
funCreateV 'eth_55644' 'eth_3356' '0' '45' '10.0.44.1/24' '10.0.44.2/24'
# node_3356-16509                        
echo "adding edge node_3356-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_3356' '0' '46' '10.0.45.1/24' '10.0.45.2/24'
# node_3356-18403                        
echo "adding edge node_3356-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_3356' '0' '47' '10.0.46.1/24' '10.0.46.2/24'
# node_3356-4809                        
echo "adding edge node_3356-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_3356' '0' '48' '10.0.47.1/24' '10.0.47.2/24'
# node_3356-4637                        
echo "adding edge node_3356-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_3356' '0' '49' '10.0.48.1/24' '10.0.48.2/24'
# node_34224-13335                        
echo "adding edge node_34224-13335"                        
sleep 1                        
funCreateV 'eth_13335' 'eth_34224' '1' '3' '10.0.59.1/24' '10.0.59.2/24'
# node_34224-6939                        
echo "adding edge node_34224-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_34224' '1' '27' '10.0.60.1/24' '10.0.60.2/24'
# node_34224-38040                        
echo "adding edge node_34224-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_34224' '1' '15' '10.0.62.1/24' '10.0.62.2/24'
# node_34224-6453                        
echo "adding edge node_34224-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_34224' '1' '22' '10.0.64.1/24' '10.0.64.2/24'
# node_34224-132203                        
echo "adding edge node_34224-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_34224' '1' '34' '10.0.68.1/24' '10.0.68.2/24'
# node_34224-9002                        
echo "adding edge node_34224-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_34224' '1' '28' '10.0.71.1/24' '10.0.71.2/24'
# node_34224-6762                        
echo "adding edge node_34224-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_34224' '1' '13' '10.0.72.1/24' '10.0.72.2/24'
# node_34224-4775                        
echo "adding edge node_34224-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_34224' '1' '44' '10.0.74.1/24' '10.0.74.2/24'
# node_34224-18403                        
echo "adding edge node_34224-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_34224' '1' '47' '10.0.77.1/24' '10.0.77.2/24'
# node_3549-4775                        
echo "adding edge node_3549-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_3549' '2' '44' '10.0.159.1/24' '10.0.159.2/24'
# node_13335-7018                        
echo "adding edge node_13335-7018"                        
sleep 1                        
funCreateV 'eth_7018' 'eth_13335' '3' '8' '10.0.82.1/24' '10.0.82.2/24'
# node_13335-3257                        
echo "adding edge node_13335-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_13335' '3' '10' '10.0.84.1/24' '10.0.84.2/24'
# node_13335-3741                        
echo "adding edge node_13335-3741"                        
sleep 1                        
funCreateV 'eth_3741' 'eth_13335' '3' '11' '10.0.86.1/24' '10.0.86.2/24'
# node_13335-57866                        
echo "adding edge node_13335-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_13335' '3' '37' '10.0.90.1/24' '10.0.90.2/24'
# node_13335-1299                        
echo "adding edge node_13335-1299"                        
sleep 1                        
funCreateV 'eth_1299' 'eth_13335' '3' '6' '10.0.92.1/24' '10.0.92.2/24'
# node_13335-2152                        
echo "adding edge node_13335-2152"                        
sleep 1                        
funCreateV 'eth_2152' 'eth_13335' '3' '16' '10.0.93.1/24' '10.0.93.2/24'
# node_13335-6939                        
echo "adding edge node_13335-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_13335' '3' '27' '10.0.94.1/24' '10.0.94.2/24'
# node_13335-2497                        
echo "adding edge node_13335-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_13335' '3' '42' '10.0.95.1/24' '10.0.95.2/24'
# node_13335-293                        
echo "adding edge node_13335-293"                        
sleep 1                        
funCreateV 'eth_293' 'eth_13335' '3' '18' '10.0.96.1/24' '10.0.96.2/24'
# node_13335-5413                        
echo "adding edge node_13335-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_13335' '3' '31' '10.0.97.1/24' '10.0.97.2/24'
# node_13335-2914                        
echo "adding edge node_13335-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_13335' '3' '12' '10.0.98.1/24' '10.0.98.2/24'
# node_13335-1239                        
echo "adding edge node_13335-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_13335' '3' '21' '10.0.101.1/24' '10.0.101.2/24'
# node_3303-6939                        
echo "adding edge node_3303-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_3303' '4' '27' '10.1.29.1/24' '10.1.29.2/24'
# node_3303-2497                        
echo "adding edge node_3303-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_3303' '4' '42' '10.1.31.1/24' '10.1.31.2/24'
# node_3303-38040                        
echo "adding edge node_3303-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_3303' '4' '15' '10.1.32.1/24' '10.1.32.2/24'
# node_3303-4837                        
echo "adding edge node_3303-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_3303' '4' '19' '10.1.34.1/24' '10.1.34.2/24'
# node_3303-6453                        
echo "adding edge node_3303-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_3303' '4' '22' '10.1.35.1/24' '10.1.35.2/24'
# node_3303-2914                        
echo "adding edge node_3303-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_3303' '4' '12' '10.1.37.1/24' '10.1.37.2/24'
# node_3303-174                        
echo "adding edge node_3303-174"                        
sleep 1                        
funCreateV 'eth_174' 'eth_3303' '4' '7' '10.1.38.1/24' '10.1.38.2/24'
# node_3303-3491                        
echo "adding edge node_3303-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_3303' '4' '26' '10.1.40.1/24' '10.1.40.2/24'
# node_3303-64049                        
echo "adding edge node_3303-64049"                        
sleep 1                        
funCreateV 'eth_64049' 'eth_3303' '4' '24' '10.1.42.1/24' '10.1.42.2/24'
# node_3303-3786                        
echo "adding edge node_3303-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_3303' '4' '30' '10.1.43.1/24' '10.1.43.2/24'
# node_3303-4134                        
echo "adding edge node_3303-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_3303' '4' '33' '10.1.45.1/24' '10.1.45.2/24'
# node_3303-132203                        
echo "adding edge node_3303-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_3303' '4' '34' '10.1.46.1/24' '10.1.46.2/24'
# node_3303-4766                        
echo "adding edge node_3303-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_3303' '4' '35' '10.1.47.1/24' '10.1.47.2/24'
# node_3303-4637                        
echo "adding edge node_3303-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_3303' '4' '49' '10.1.49.1/24' '10.1.49.2/24'
# node_3303-1273                        
echo "adding edge node_3303-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_3303' '4' '20' '10.1.50.1/24' '10.1.50.2/24'
# node_3303-9002                        
echo "adding edge node_3303-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_3303' '4' '28' '10.1.52.1/24' '10.1.52.2/24'
# node_3303-6461                        
echo "adding edge node_3303-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_3303' '4' '25' '10.1.53.1/24' '10.1.53.2/24'
# node_3303-3257                        
echo "adding edge node_3303-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_3303' '4' '10' '10.0.149.2/24' '10.0.149.1/24'
# node_1299-7018                        
echo "adding edge node_1299-7018"                        
sleep 1                        
funCreateV 'eth_7018' 'eth_1299' '6' '8' '10.0.102.2/24' '10.0.102.1/24'
# node_1299-3257                        
echo "adding edge node_1299-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_1299' '6' '10' '10.0.125.2/24' '10.0.125.1/24'
# node_1299-57866                        
echo "adding edge node_1299-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_1299' '6' '37' '10.0.220.2/24' '10.0.220.1/24'
# node_1299-2519                        
echo "adding edge node_1299-2519"                        
sleep 1                        
funCreateV 'eth_2519' 'eth_1299' '6' '9' '10.0.237.1/24' '10.0.237.2/24'
# node_1299-2497                        
echo "adding edge node_1299-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_1299' '6' '42' '10.0.240.1/24' '10.0.240.2/24'
# node_1299-38040                        
echo "adding edge node_1299-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_1299' '6' '15' '10.0.241.1/24' '10.0.241.2/24'
# node_1299-4837                        
echo "adding edge node_1299-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_1299' '6' '19' '10.0.243.1/24' '10.0.243.2/24'
# node_1299-5413                        
echo "adding edge node_1299-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_1299' '6' '31' '10.0.244.1/24' '10.0.244.2/24'
# node_1299-2914                        
echo "adding edge node_1299-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_1299' '6' '12' '10.0.245.1/24' '10.0.245.2/24'
# node_1299-31133                        
echo "adding edge node_1299-31133"                        
sleep 1                        
funCreateV 'eth_31133' 'eth_1299' '6' '23' '10.0.248.1/24' '10.0.248.2/24'
# node_1299-174                        
echo "adding edge node_1299-174"                        
sleep 1                        
funCreateV 'eth_174' 'eth_1299' '6' '7' '10.0.249.1/24' '10.0.249.2/24'
# node_1299-6453                        
echo "adding edge node_1299-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_1299' '6' '22' '10.0.250.1/24' '10.0.250.2/24'
# node_1299-6939                        
echo "adding edge node_1299-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_1299' '6' '27' '10.0.251.1/24' '10.0.251.2/24'
# node_1299-6762                        
echo "adding edge node_1299-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_1299' '6' '13' '10.0.252.1/24' '10.0.252.2/24'
# node_1299-1273                        
echo "adding edge node_1299-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_1299' '6' '20' '10.0.253.1/24' '10.0.253.2/24'
# node_1299-64049                        
echo "adding edge node_1299-64049"                        
sleep 1                        
funCreateV 'eth_64049' 'eth_1299' '6' '24' '10.0.254.1/24' '10.0.254.2/24'
# node_1299-1239                        
echo "adding edge node_1299-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_1299' '6' '21' '10.0.255.1/24' '10.0.255.2/24'
# node_1299-6461                        
echo "adding edge node_1299-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_1299' '6' '25' '10.1.0.1/24' '10.1.0.2/24'
# node_1299-3491                        
echo "adding edge node_1299-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_1299' '6' '26' '10.1.1.1/24' '10.1.1.2/24'
# node_1299-37100                        
echo "adding edge node_1299-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_1299' '6' '29' '10.1.3.1/24' '10.1.3.2/24'
# node_1299-4134                        
echo "adding edge node_1299-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_1299' '6' '33' '10.1.5.1/24' '10.1.5.2/24'
# node_1299-132203                        
echo "adding edge node_1299-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_1299' '6' '34' '10.1.6.1/24' '10.1.6.2/24'
# node_1299-4766                        
echo "adding edge node_1299-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_1299' '6' '35' '10.1.7.1/24' '10.1.7.2/24'
# node_1299-9002                        
echo "adding edge node_1299-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_1299' '6' '28' '10.1.12.1/24' '10.1.12.2/24'
# node_1299-9680                        
echo "adding edge node_1299-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_1299' '6' '43' '10.1.13.1/24' '10.1.13.2/24'
# node_1299-4775                        
echo "adding edge node_1299-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_1299' '6' '44' '10.1.14.1/24' '10.1.14.2/24'
# node_1299-16509                        
echo "adding edge node_1299-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_1299' '6' '46' '10.1.15.1/24' '10.1.15.2/24'
# node_1299-18403                        
echo "adding edge node_1299-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_1299' '6' '47' '10.1.20.1/24' '10.1.20.2/24'
# node_1299-4809                        
echo "adding edge node_1299-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_1299' '6' '48' '10.1.22.1/24' '10.1.22.2/24'
# node_1299-4637                        
echo "adding edge node_1299-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_1299' '6' '49' '10.1.23.1/24' '10.1.23.2/24'
# node_1299-5511                        
echo "adding edge node_1299-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_1299' '6' '17' '10.1.26.1/24' '10.1.26.2/24'
# node_174-2519                        
echo "adding edge node_174-2519"                        
sleep 1                        
funCreateV 'eth_2519' 'eth_174' '7' '9' '10.2.56.1/24' '10.2.56.2/24'
# node_174-3741                        
echo "adding edge node_174-3741"                        
sleep 1                        
funCreateV 'eth_3741' 'eth_174' '7' '11' '10.0.163.2/24' '10.0.163.1/24'
# node_174-5511                        
echo "adding edge node_174-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_174' '7' '17' '10.2.57.1/24' '10.2.57.2/24'
# node_174-3491                        
echo "adding edge node_174-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_174' '7' '26' '10.2.58.1/24' '10.2.58.2/24'
# node_174-37100                        
echo "adding edge node_174-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_174' '7' '29' '10.2.40.2/24' '10.2.40.1/24'
# node_174-7018                        
echo "adding edge node_174-7018"                        
sleep 1                        
funCreateV 'eth_7018' 'eth_174' '7' '8' '10.0.109.2/24' '10.0.109.1/24'
# node_174-3257                        
echo "adding edge node_174-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_174' '7' '10' '10.0.134.2/24' '10.0.134.1/24'
# node_174-31133                        
echo "adding edge node_174-31133"                        
sleep 1                        
funCreateV 'eth_31133' 'eth_174' '7' '23' '10.2.61.1/24' '10.2.61.2/24'
# node_174-2914                        
echo "adding edge node_174-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_174' '7' '12' '10.1.208.2/24' '10.1.208.1/24'
# node_174-1239                        
echo "adding edge node_174-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_174' '7' '21' '10.2.19.2/24' '10.2.19.1/24'
# node_174-6453                        
echo "adding edge node_174-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_174' '7' '22' '10.2.62.1/24' '10.2.62.2/24'
# node_174-38040                        
echo "adding edge node_174-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_174' '7' '15' '10.2.65.1/24' '10.2.65.2/24'
# node_174-4134                        
echo "adding edge node_174-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_174' '7' '33' '10.2.67.1/24' '10.2.67.2/24'
# node_174-2497                        
echo "adding edge node_174-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_174' '7' '42' '10.1.155.2/24' '10.1.155.1/24'
# node_174-1273                        
echo "adding edge node_174-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_174' '7' '20' '10.2.73.1/24' '10.2.73.2/24'
# node_174-6461                        
echo "adding edge node_174-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_174' '7' '25' '10.2.75.1/24' '10.2.75.2/24'
# node_174-9680                        
echo "adding edge node_174-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_174' '7' '43' '10.2.76.1/24' '10.2.76.2/24'
# node_174-55644                        
echo "adding edge node_174-55644"                        
sleep 1                        
funCreateV 'eth_55644' 'eth_174' '7' '45' '10.2.77.1/24' '10.2.77.2/24'
# node_174-16509                        
echo "adding edge node_174-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_174' '7' '46' '10.2.78.1/24' '10.2.78.2/24'
# node_174-4837                        
echo "adding edge node_174-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_174' '7' '19' '10.2.79.1/24' '10.2.79.2/24'
# node_174-6762                        
echo "adding edge node_174-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_174' '7' '13' '10.2.81.1/24' '10.2.81.2/24'
# node_174-3786                        
echo "adding edge node_174-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_174' '7' '30' '10.2.83.1/24' '10.2.83.2/24'
# node_7018-2914                        
echo "adding edge node_7018-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_7018' '8' '12' '10.0.103.1/24' '10.0.103.2/24'
# node_7018-2497                        
echo "adding edge node_7018-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_7018' '8' '42' '10.0.104.1/24' '10.0.104.2/24'
# node_7018-6453                        
echo "adding edge node_7018-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_7018' '8' '22' '10.0.105.1/24' '10.0.105.2/24'
# node_7018-5511                        
echo "adding edge node_7018-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_7018' '8' '17' '10.0.106.1/24' '10.0.106.2/24'
# node_7018-4837                        
echo "adding edge node_7018-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_7018' '8' '19' '10.0.107.1/24' '10.0.107.2/24'
# node_7018-1239                        
echo "adding edge node_7018-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_7018' '8' '21' '10.0.108.1/24' '10.0.108.2/24'
# node_7018-6461                        
echo "adding edge node_7018-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_7018' '8' '25' '10.0.110.1/24' '10.0.110.2/24'
# node_7018-3491                        
echo "adding edge node_7018-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_7018' '8' '26' '10.0.111.1/24' '10.0.111.2/24'
# node_7018-4134                        
echo "adding edge node_7018-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_7018' '8' '33' '10.0.112.1/24' '10.0.112.2/24'
# node_7018-701                        
echo "adding edge node_7018-701"                        
sleep 1                        
funCreateV 'eth_701' 'eth_7018' '8' '32' '10.0.113.1/24' '10.0.113.2/24'
# node_7018-6939                        
echo "adding edge node_7018-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_7018' '8' '27' '10.0.114.1/24' '10.0.114.2/24'
# node_7018-9680                        
echo "adding edge node_7018-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_7018' '8' '43' '10.0.115.1/24' '10.0.115.2/24'
# node_7018-4775                        
echo "adding edge node_7018-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_7018' '8' '44' '10.0.116.1/24' '10.0.116.2/24'
# node_7018-16509                        
echo "adding edge node_7018-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_7018' '8' '46' '10.0.117.1/24' '10.0.117.2/24'
# node_7018-3257                        
echo "adding edge node_7018-3257"                        
sleep 1                        
funCreateV 'eth_3257' 'eth_7018' '8' '10' '10.0.118.1/24' '10.0.118.2/24'
# node_7018-6762                        
echo "adding edge node_7018-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_7018' '8' '13' '10.0.120.1/24' '10.0.120.2/24'
# node_2519-2497                        
echo "adding edge node_2519-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_2519' '9' '42' '10.1.137.2/24' '10.1.137.1/24'
# node_2519-4637                        
echo "adding edge node_2519-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_2519' '9' '49' '10.2.112.1/24' '10.2.112.2/24'
# node_2519-6939                        
echo "adding edge node_2519-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_2519' '9' '27' '10.1.83.2/24' '10.1.83.1/24'
# node_3257-2914                        
echo "adding edge node_3257-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_3257' '10' '12' '10.0.126.1/24' '10.0.126.2/24'
# node_3257-2497                        
echo "adding edge node_3257-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_3257' '10' '42' '10.0.127.1/24' '10.0.127.2/24'
# node_3257-37100                        
echo "adding edge node_3257-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_3257' '10' '29' '10.0.129.1/24' '10.0.129.2/24'
# node_3257-4837                        
echo "adding edge node_3257-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_3257' '10' '19' '10.0.130.1/24' '10.0.130.2/24'
# node_3257-3491                        
echo "adding edge node_3257-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_3257' '10' '26' '10.0.131.1/24' '10.0.131.2/24'
# node_3257-6453                        
echo "adding edge node_3257-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_3257' '10' '22' '10.0.135.1/24' '10.0.135.2/24'
# node_3257-6461                        
echo "adding edge node_3257-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_3257' '10' '25' '10.0.136.1/24' '10.0.136.2/24'
# node_3257-4134                        
echo "adding edge node_3257-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_3257' '10' '33' '10.0.137.1/24' '10.0.137.2/24'
# node_3257-4766                        
echo "adding edge node_3257-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_3257' '10' '35' '10.0.138.1/24' '10.0.138.2/24'
# node_3257-1239                        
echo "adding edge node_3257-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_3257' '10' '21' '10.0.140.1/24' '10.0.140.2/24'
# node_3257-1273                        
echo "adding edge node_3257-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_3257' '10' '20' '10.0.141.1/24' '10.0.141.2/24'
# node_3257-16509                        
echo "adding edge node_3257-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_3257' '10' '46' '10.0.144.1/24' '10.0.144.2/24'
# node_3257-4637                        
echo "adding edge node_3257-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_3257' '10' '49' '10.0.150.1/24' '10.0.150.2/24'
# node_3257-5511                        
echo "adding edge node_3257-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_3257' '10' '17' '10.0.152.1/24' '10.0.152.2/24'
# node_3257-6762                        
echo "adding edge node_3257-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_3257' '10' '13' '10.0.154.1/24' '10.0.154.2/24'
# node_3741-6939                        
echo "adding edge node_3741-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_3741' '11' '27' '10.0.160.1/24' '10.0.160.2/24'
# node_3741-9002                        
echo "adding edge node_3741-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_3741' '11' '28' '10.0.164.1/24' '10.0.164.2/24'
# node_3741-4134                        
echo "adding edge node_3741-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_3741' '11' '33' '10.0.165.1/24' '10.0.165.2/24'
# node_3741-2914                        
echo "adding edge node_3741-2914"                        
sleep 1                        
funCreateV 'eth_2914' 'eth_3741' '11' '12' '10.0.166.1/24' '10.0.166.2/24'
# node_3741-6461                        
echo "adding edge node_3741-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_3741' '11' '25' '10.0.167.1/24' '10.0.167.2/24'
# node_3741-64049                        
echo "adding edge node_3741-64049"                        
sleep 1                        
funCreateV 'eth_64049' 'eth_3741' '11' '24' '10.0.168.1/24' '10.0.168.2/24'
# node_2914-6453                        
echo "adding edge node_2914-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_2914' '12' '22' '10.1.194.1/24' '10.1.194.2/24'
# node_2914-293                        
echo "adding edge node_2914-293"                        
sleep 1                        
funCreateV 'eth_293' 'eth_2914' '12' '18' '10.1.171.2/24' '10.1.171.1/24'
# node_2914-6461                        
echo "adding edge node_2914-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_2914' '12' '25' '10.1.196.1/24' '10.1.196.2/24'
# node_2914-57866                        
echo "adding edge node_2914-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_2914' '12' '37' '10.0.221.2/24' '10.0.221.1/24'
# node_2914-4637                        
echo "adding edge node_2914-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_2914' '12' '49' '10.1.197.1/24' '10.1.197.2/24'
# node_2914-38040                        
echo "adding edge node_2914-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_2914' '12' '15' '10.1.198.1/24' '10.1.198.2/24'
# node_2914-4837                        
echo "adding edge node_2914-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_2914' '12' '19' '10.1.200.1/24' '10.1.200.2/24'
# node_2914-1239                        
echo "adding edge node_2914-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_2914' '12' '21' '10.1.205.1/24' '10.1.205.2/24'
# node_2914-37100                        
echo "adding edge node_2914-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_2914' '12' '29' '10.1.206.1/24' '10.1.206.2/24'
# node_2914-3491                        
echo "adding edge node_2914-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_2914' '12' '26' '10.1.207.1/24' '10.1.207.2/24'
# node_2914-2497                        
echo "adding edge node_2914-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_2914' '12' '42' '10.1.140.2/24' '10.1.140.1/24'
# node_2914-64049                        
echo "adding edge node_2914-64049"                        
sleep 1                        
funCreateV 'eth_64049' 'eth_2914' '12' '24' '10.1.209.1/24' '10.1.209.2/24'
# node_2914-3786                        
echo "adding edge node_2914-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_2914' '12' '30' '10.1.212.1/24' '10.1.212.2/24'
# node_2914-4134                        
echo "adding edge node_2914-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_2914' '12' '33' '10.1.215.1/24' '10.1.215.2/24'
# node_2914-132203                        
echo "adding edge node_2914-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_2914' '12' '34' '10.1.216.1/24' '10.1.216.2/24'
# node_2914-4766                        
echo "adding edge node_2914-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_2914' '12' '35' '10.1.217.1/24' '10.1.217.2/24'
# node_2914-6762                        
echo "adding edge node_2914-6762"                        
sleep 1                        
funCreateV 'eth_6762' 'eth_2914' '12' '13' '10.1.220.1/24' '10.1.220.2/24'
# node_2914-1273                        
echo "adding edge node_2914-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_2914' '12' '20' '10.1.224.1/24' '10.1.224.2/24'
# node_2914-4775                        
echo "adding edge node_2914-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_2914' '12' '44' '10.1.229.1/24' '10.1.229.2/24'
# node_2914-16509                        
echo "adding edge node_2914-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_2914' '12' '46' '10.1.230.1/24' '10.1.230.2/24'
# node_2914-18403                        
echo "adding edge node_2914-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_2914' '12' '47' '10.1.234.1/24' '10.1.234.2/24'
# node_2914-4809                        
echo "adding edge node_2914-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_2914' '12' '48' '10.1.236.1/24' '10.1.236.2/24'
# node_2914-5413                        
echo "adding edge node_2914-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_2914' '12' '31' '10.1.192.2/24' '10.1.192.1/24'
# node_2914-5511                        
echo "adding edge node_2914-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_2914' '12' '17' '10.1.238.1/24' '10.1.238.2/24'
# node_6762-37100                        
echo "adding edge node_6762-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_6762' '13' '29' '10.2.41.2/24' '10.2.41.1/24'
# node_6762-6453                        
echo "adding edge node_6762-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_6762' '13' '22' '10.2.95.2/24' '10.2.95.1/24'
# node_6762-38040                        
echo "adding edge node_6762-38040"                        
sleep 1                        
funCreateV 'eth_38040' 'eth_6762' '13' '15' '10.2.170.1/24' '10.2.170.2/24'
# node_6762-9680                        
echo "adding edge node_6762-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_6762' '13' '43' '10.2.171.1/24' '10.2.171.2/24'
# node_6762-1273                        
echo "adding edge node_6762-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_6762' '13' '20' '10.2.173.1/24' '10.2.173.2/24'
# node_6762-3491                        
echo "adding edge node_6762-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_6762' '13' '26' '10.2.174.1/24' '10.2.174.2/24'
# node_6762-4134                        
echo "adding edge node_6762-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_6762' '13' '33' '10.2.175.1/24' '10.2.175.2/24'
# node_6762-6939                        
echo "adding edge node_6762-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_6762' '13' '27' '10.1.131.2/24' '10.1.131.1/24'
# node_6762-5511                        
echo "adding edge node_6762-5511"                        
sleep 1                        
funCreateV 'eth_5511' 'eth_6762' '13' '17' '10.2.177.1/24' '10.2.177.2/24'
# node_6762-1239                        
echo "adding edge node_6762-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_6762' '13' '21' '10.2.34.2/24' '10.2.34.1/24'
# node_2516-2152                        
echo "adding edge node_2516-2152"                        
sleep 1                        
funCreateV 'eth_2152' 'eth_2516' '14' '16' '10.1.61.2/24' '10.1.61.1/24'
# node_38040-6939                        
echo "adding edge node_38040-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_38040' '15' '27' '10.1.86.2/24' '10.1.86.1/24'
# node_38040-6453                        
echo "adding edge node_38040-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_38040' '15' '22' '10.2.85.2/24' '10.2.85.1/24'
# node_38040-2497                        
echo "adding edge node_38040-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_38040' '15' '42' '10.1.145.2/24' '10.1.145.1/24'
# node_38040-9002                        
echo "adding edge node_38040-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_38040' '15' '28' '10.2.219.1/24' '10.2.219.2/24'
# node_38040-3491                        
echo "adding edge node_38040-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_38040' '15' '26' '10.2.220.1/24' '10.2.220.2/24'
# node_38040-12552                        
echo "adding edge node_38040-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_38040' '15' '36' '10.2.132.2/24' '10.2.132.1/24'
# node_38040-293                        
echo "adding edge node_38040-293"                        
sleep 1                        
funCreateV 'eth_293' 'eth_38040' '15' '18' '10.1.182.2/24' '10.1.182.1/24'
# node_2152-6939                        
echo "adding edge node_2152-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_2152' '16' '27' '10.1.58.1/24' '10.1.58.2/24'
# node_2152-1239                        
echo "adding edge node_2152-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_2152' '16' '21' '10.1.60.1/24' '10.1.60.2/24'
# node_2152-6461                        
echo "adding edge node_2152-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_2152' '16' '25' '10.1.62.1/24' '10.1.62.2/24'
# node_2152-3786                        
echo "adding edge node_2152-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_2152' '16' '30' '10.1.64.1/24' '10.1.64.2/24'
# node_2152-132203                        
echo "adding edge node_2152-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_2152' '16' '34' '10.1.66.1/24' '10.1.66.2/24'
# node_2152-4766                        
echo "adding edge node_2152-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_2152' '16' '35' '10.1.67.1/24' '10.1.67.2/24'
# node_2152-9680                        
echo "adding edge node_2152-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_2152' '16' '43' '10.1.68.1/24' '10.1.68.2/24'
# node_2152-16509                        
echo "adding edge node_2152-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_2152' '16' '46' '10.1.69.1/24' '10.1.69.2/24'
# node_5511-4837                        
echo "adding edge node_5511-4837"                        
sleep 1                        
funCreateV 'eth_4837' 'eth_5511' '17' '19' '10.3.8.2/24' '10.3.8.1/24'
# node_5511-6939                        
echo "adding edge node_5511-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_5511' '17' '27' '10.1.88.2/24' '10.1.88.1/24'
# node_5511-1239                        
echo "adding edge node_5511-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_5511' '17' '21' '10.2.16.2/24' '10.2.16.1/24'
# node_5511-6461                        
echo "adding edge node_5511-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_5511' '17' '25' '10.2.195.2/24' '10.2.195.1/24'
# node_5511-2497                        
echo "adding edge node_5511-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_5511' '17' '42' '10.1.169.2/24' '10.1.169.1/24'
# node_5511-6453                        
echo "adding edge node_5511-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_5511' '17' '22' '10.2.109.2/24' '10.2.109.1/24'
# node_293-6939                        
echo "adding edge node_293-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_293' '18' '27' '10.1.81.2/24' '10.1.81.1/24'
# node_293-2497                        
echo "adding edge node_293-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_293' '18' '42' '10.1.144.2/24' '10.1.144.1/24'
# node_293-6453                        
echo "adding edge node_293-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_293' '18' '22' '10.1.172.1/24' '10.1.172.2/24'
# node_293-3491                        
echo "adding edge node_293-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_293' '18' '26' '10.1.173.1/24' '10.1.173.2/24'
# node_293-1273                        
echo "adding edge node_293-1273"                        
sleep 1                        
funCreateV 'eth_1273' 'eth_293' '18' '20' '10.1.175.1/24' '10.1.175.2/24'
# node_293-9002                        
echo "adding edge node_293-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_293' '18' '28' '10.1.177.1/24' '10.1.177.2/24'
# node_4837-6461                        
echo "adding edge node_4837-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_4837' '19' '25' '10.2.183.2/24' '10.2.183.1/24'
# node_4837-6453                        
echo "adding edge node_4837-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_4837' '19' '22' '10.2.86.2/24' '10.2.86.1/24'
# node_4837-2497                        
echo "adding edge node_4837-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_4837' '19' '42' '10.1.146.2/24' '10.1.146.1/24'
# node_4837-6939                        
echo "adding edge node_4837-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_4837' '19' '27' '10.1.108.2/24' '10.1.108.1/24'
# node_4837-4134                        
echo "adding edge node_4837-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_4837' '19' '33' '10.3.12.1/24' '10.3.12.2/24'
# node_4837-701                        
echo "adding edge node_4837-701"                        
sleep 1                        
funCreateV 'eth_701' 'eth_4837' '19' '32' '10.3.14.1/24' '10.3.14.2/24'
# node_4837-1239                        
echo "adding edge node_4837-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_4837' '19' '21' '10.2.25.2/24' '10.2.25.1/24'
# node_1273-6453                        
echo "adding edge node_1273-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_1273' '20' '22' '10.2.96.2/24' '10.2.96.1/24'
# node_1273-55410                        
echo "adding edge node_1273-55410"                        
sleep 1                        
funCreateV 'eth_55410' 'eth_1273' '20' '41' '10.3.84.1/24' '10.3.84.2/24'
# node_1273-2497                        
echo "adding edge node_1273-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_1273' '20' '42' '10.1.158.2/24' '10.1.158.1/24'
# node_1273-1239                        
echo "adding edge node_1273-1239"                        
sleep 1                        
funCreateV 'eth_1239' 'eth_1273' '20' '21' '10.2.24.2/24' '10.2.24.1/24'
# node_1273-6939                        
echo "adding edge node_1273-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_1273' '20' '27' '10.1.106.2/24' '10.1.106.1/24'
# node_1273-6461                        
echo "adding edge node_1273-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_1273' '20' '25' '10.2.191.2/24' '10.2.191.1/24'
# node_1273-55644                        
echo "adding edge node_1273-55644"                        
sleep 1                        
funCreateV 'eth_55644' 'eth_1273' '20' '45' '10.3.87.1/24' '10.3.87.2/24'
# node_1239-4766                        
echo "adding edge node_1239-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_1239' '21' '35' '10.2.15.1/24' '10.2.15.2/24'
# node_1239-6453                        
echo "adding edge node_1239-6453"                        
sleep 1                        
funCreateV 'eth_6453' 'eth_1239' '21' '22' '10.2.17.1/24' '10.2.17.2/24'
# node_1239-6939                        
echo "adding edge node_1239-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_1239' '21' '27' '10.1.90.2/24' '10.1.90.1/24'
# node_1239-6461                        
echo "adding edge node_1239-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_1239' '21' '25' '10.2.20.1/24' '10.2.20.2/24'
# node_1239-3491                        
echo "adding edge node_1239-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_1239' '21' '26' '10.2.21.1/24' '10.2.21.2/24'
# node_1239-3786                        
echo "adding edge node_1239-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_1239' '21' '30' '10.2.22.1/24' '10.2.22.2/24'
# node_1239-701                        
echo "adding edge node_1239-701"                        
sleep 1                        
funCreateV 'eth_701' 'eth_1239' '21' '32' '10.2.26.1/24' '10.2.26.2/24'
# node_1239-4775                        
echo "adding edge node_1239-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_1239' '21' '44' '10.2.29.1/24' '10.2.29.2/24'
# node_1239-16509                        
echo "adding edge node_1239-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_1239' '21' '46' '10.2.30.1/24' '10.2.30.2/24'
# node_6453-2497                        
echo "adding edge node_6453-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_6453' '22' '42' '10.1.135.2/24' '10.1.135.1/24'
# node_6453-37100                        
echo "adding edge node_6453-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_6453' '22' '29' '10.2.38.2/24' '10.2.38.1/24'
# node_6453-6461                        
echo "adding edge node_6453-6461"                        
sleep 1                        
funCreateV 'eth_6461' 'eth_6453' '22' '25' '10.2.88.1/24' '10.2.88.2/24'
# node_6453-57866                        
echo "adding edge node_6453-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_6453' '22' '37' '10.0.224.2/24' '10.0.224.1/24'
# node_6453-4134                        
echo "adding edge node_6453-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_6453' '22' '33' '10.2.99.1/24' '10.2.99.2/24'
# node_6453-9002                        
echo "adding edge node_6453-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_6453' '22' '28' '10.2.101.1/24' '10.2.101.2/24'
# node_6453-3491                        
echo "adding edge node_6453-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_6453' '22' '26' '10.2.102.1/24' '10.2.102.2/24'
# node_6453-4775                        
echo "adding edge node_6453-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_6453' '22' '44' '10.2.104.1/24' '10.2.104.2/24'
# node_6453-16509                        
echo "adding edge node_6453-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_6453' '22' '46' '10.2.105.1/24' '10.2.105.2/24'
# node_6453-18403                        
echo "adding edge node_6453-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_6453' '22' '47' '10.2.107.1/24' '10.2.107.2/24'
# node_6453-4637                        
echo "adding edge node_6453-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_6453' '22' '49' '10.2.108.1/24' '10.2.108.2/24'
# node_6453-3786                        
echo "adding edge node_6453-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_6453' '22' '30' '10.2.111.1/24' '10.2.111.2/24'
# node_31133-4637                        
echo "adding edge node_31133-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_31133' '23' '49' '10.2.135.2/24' '10.2.135.1/24'
# node_31133-3786                        
echo "adding edge node_31133-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_31133' '23' '30' '10.2.148.1/24' '10.2.148.2/24'
# node_31133-4134                        
echo "adding edge node_31133-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_31133' '23' '33' '10.2.149.1/24' '10.2.149.2/24'
# node_31133-4766                        
echo "adding edge node_31133-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_31133' '23' '35' '10.2.150.1/24' '10.2.150.2/24'
# node_31133-18403                        
echo "adding edge node_31133-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_31133' '23' '47' '10.2.156.1/24' '10.2.156.2/24'
# node_64049-37100                        
echo "adding edge node_64049-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_64049' '24' '29' '10.2.43.2/24' '10.2.43.1/24'
# node_64049-6939                        
echo "adding edge node_64049-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_64049' '24' '27' '10.1.92.2/24' '10.1.92.1/24'
# node_64049-12552                        
echo "adding edge node_64049-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_64049' '24' '36' '10.2.118.2/24' '10.2.118.1/24'
# node_6461-57866                        
echo "adding edge node_6461-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_6461' '25' '37' '10.0.223.2/24' '10.0.223.1/24'
# node_6461-5413                        
echo "adding edge node_6461-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_6461' '25' '31' '10.1.187.2/24' '10.1.187.1/24'
# node_6461-37100                        
echo "adding edge node_6461-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_6461' '25' '29' '10.2.42.2/24' '10.2.42.1/24'
# node_6461-12552                        
echo "adding edge node_6461-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_6461' '25' '36' '10.2.119.2/24' '10.2.119.1/24'
# node_6461-3491                        
echo "adding edge node_6461-3491"                        
sleep 1                        
funCreateV 'eth_3491' 'eth_6461' '25' '26' '10.2.185.1/24' '10.2.185.2/24'
# node_6461-4134                        
echo "adding edge node_6461-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_6461' '25' '33' '10.2.187.1/24' '10.2.187.2/24'
# node_6461-132203                        
echo "adding edge node_6461-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_6461' '25' '34' '10.2.188.1/24' '10.2.188.2/24'
# node_6461-9002                        
echo "adding edge node_6461-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_6461' '25' '28' '10.2.192.1/24' '10.2.192.2/24'
# node_6461-9680                        
echo "adding edge node_6461-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_6461' '25' '43' '10.2.193.1/24' '10.2.193.2/24'
# node_6461-6939                        
echo "adding edge node_6461-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_6461' '25' '27' '10.1.118.2/24' '10.1.118.1/24'
# node_6461-2497                        
echo "adding edge node_6461-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_6461' '25' '42' '10.1.163.2/24' '10.1.163.1/24'
# node_6461-4637                        
echo "adding edge node_6461-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_6461' '25' '49' '10.2.147.2/24' '10.2.147.1/24'
# node_3491-2497                        
echo "adding edge node_3491-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_3491' '26' '42' '10.1.147.2/24' '10.1.147.1/24'
# node_3491-6939                        
echo "adding edge node_3491-6939"                        
sleep 1                        
funCreateV 'eth_6939' 'eth_3491' '26' '27' '10.1.93.2/24' '10.1.93.1/24'
# node_3491-132203                        
echo "adding edge node_3491-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_3491' '26' '34' '10.3.47.1/24' '10.3.47.2/24'
# node_3491-5413                        
echo "adding edge node_3491-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_3491' '26' '31' '10.1.191.2/24' '10.1.191.1/24'
# node_3491-55644                        
echo "adding edge node_3491-55644"                        
sleep 1                        
funCreateV 'eth_55644' 'eth_3491' '26' '45' '10.3.51.1/24' '10.3.51.2/24'
# node_3491-18403                        
echo "adding edge node_3491-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_3491' '26' '47' '10.3.53.1/24' '10.3.53.2/24'
# node_3491-4809                        
echo "adding edge node_3491-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_3491' '26' '48' '10.3.56.1/24' '10.3.56.2/24'
# node_6939-37100                        
echo "adding edge node_6939-37100"                        
sleep 1                        
funCreateV 'eth_37100' 'eth_6939' '27' '29' '10.1.75.1/24' '10.1.75.2/24'
# node_6939-5413                        
echo "adding edge node_6939-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_6939' '27' '31' '10.1.78.1/24' '10.1.78.2/24'
# node_6939-2497                        
echo "adding edge node_6939-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_6939' '27' '42' '10.1.95.1/24' '10.1.95.2/24'
# node_6939-3786                        
echo "adding edge node_6939-3786"                        
sleep 1                        
funCreateV 'eth_3786' 'eth_6939' '27' '30' '10.1.96.1/24' '10.1.96.2/24'
# node_6939-4134                        
echo "adding edge node_6939-4134"                        
sleep 1                        
funCreateV 'eth_4134' 'eth_6939' '27' '33' '10.1.99.1/24' '10.1.99.2/24'
# node_6939-132203                        
echo "adding edge node_6939-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_6939' '27' '34' '10.1.100.1/24' '10.1.100.2/24'
# node_6939-4766                        
echo "adding edge node_6939-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_6939' '27' '35' '10.1.101.1/24' '10.1.101.2/24'
# node_6939-12552                        
echo "adding edge node_6939-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_6939' '27' '36' '10.1.102.1/24' '10.1.102.2/24'
# node_6939-701                        
echo "adding edge node_6939-701"                        
sleep 1                        
funCreateV 'eth_701' 'eth_6939' '27' '32' '10.1.109.1/24' '10.1.109.2/24'
# node_6939-9002                        
echo "adding edge node_6939-9002"                        
sleep 1                        
funCreateV 'eth_9002' 'eth_6939' '27' '28' '10.1.111.1/24' '10.1.111.2/24'
# node_6939-9680                        
echo "adding edge node_6939-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_6939' '27' '43' '10.1.114.1/24' '10.1.114.2/24'
# node_6939-4775                        
echo "adding edge node_6939-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_6939' '27' '44' '10.1.117.1/24' '10.1.117.2/24'
# node_6939-16509                        
echo "adding edge node_6939-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_6939' '27' '46' '10.1.119.1/24' '10.1.119.2/24'
# node_6939-18403                        
echo "adding edge node_6939-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_6939' '27' '47' '10.1.123.1/24' '10.1.123.2/24'
# node_6939-4809                        
echo "adding edge node_6939-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_6939' '27' '48' '10.1.125.1/24' '10.1.125.2/24'
# node_6939-4637                        
echo "adding edge node_6939-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_6939' '27' '49' '10.1.128.1/24' '10.1.128.2/24'
# node_9002-57866                        
echo "adding edge node_9002-57866"                        
sleep 1                        
funCreateV 'eth_57866' 'eth_9002' '28' '37' '10.0.225.2/24' '10.0.225.1/24'
# node_9002-12552                        
echo "adding edge node_9002-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_9002' '28' '36' '10.2.124.2/24' '10.2.124.1/24'
# node_9002-5413                        
echo "adding edge node_9002-5413"                        
sleep 1                        
funCreateV 'eth_5413' 'eth_9002' '28' '31' '10.1.190.2/24' '10.1.190.1/24'
# node_37100-2497                        
echo "adding edge node_37100-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_37100' '29' '42' '10.1.136.2/24' '10.1.136.1/24'
# node_37100-132203                        
echo "adding edge node_37100-132203"                        
sleep 1                        
funCreateV 'eth_132203' 'eth_37100' '29' '34' '10.2.45.1/24' '10.2.45.2/24'
# node_37100-4775                        
echo "adding edge node_37100-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_37100' '29' '44' '10.2.50.1/24' '10.2.50.2/24'
# node_3786-2497                        
echo "adding edge node_3786-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_3786' '30' '42' '10.1.151.2/24' '10.1.151.1/24'
# node_3786-4637                        
echo "adding edge node_3786-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_3786' '30' '49' '10.2.146.2/24' '10.2.146.1/24'
# node_5413-4637                        
echo "adding edge node_5413-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_5413' '31' '49' '10.1.184.1/24' '10.1.184.2/24'
# node_701-9680                        
echo "adding edge node_701-9680"                        
sleep 1                        
funCreateV 'eth_9680' 'eth_701' '32' '43' '10.3.168.1/24' '10.3.168.2/24'
# node_4134-2497                        
echo "adding edge node_4134-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_4134' '33' '42' '10.1.153.2/24' '10.1.153.1/24'
# node_4134-4809                        
echo "adding edge node_4134-4809"                        
sleep 1                        
funCreateV 'eth_4809' 'eth_4134' '33' '48' '10.3.81.1/24' '10.3.81.2/24'
# node_132203-12552                        
echo "adding edge node_132203-12552"                        
sleep 1                        
funCreateV 'eth_12552' 'eth_132203' '34' '36' '10.2.121.2/24' '10.2.121.1/24'
# node_132203-4766                        
echo "adding edge node_132203-4766"                        
sleep 1                        
funCreateV 'eth_4766' 'eth_132203' '34' '35' '10.3.0.2/24' '10.3.0.1/24'
# node_4766-2497                        
echo "adding edge node_4766-2497"                        
sleep 1                        
funCreateV 'eth_2497' 'eth_4766' '35' '42' '10.1.154.2/24' '10.1.154.1/24'
# node_4766-4775                        
echo "adding edge node_4766-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_4766' '35' '44' '10.2.253.1/24' '10.2.253.2/24'
# node_12552-4637                        
echo "adding edge node_12552-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_12552' '36' '49' '10.2.114.1/24' '10.2.114.2/24'
# node_12552-18403                        
echo "adding edge node_12552-18403"                        
sleep 1                        
funCreateV 'eth_18403' 'eth_12552' '36' '47' '10.2.127.1/24' '10.2.127.2/24'
# node_9607-4637                        
echo "adding edge node_9607-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_9607' '40' '49' '10.2.138.2/24' '10.2.138.1/24'
# node_55410-55644                        
echo "adding edge node_55410-55644"                        
sleep 1                        
funCreateV 'eth_55644' 'eth_55410' '41' '45' '10.3.179.1/24' '10.3.179.2/24'
# node_2497-4775                        
echo "adding edge node_2497-4775"                        
sleep 1                        
funCreateV 'eth_4775' 'eth_2497' '42' '44' '10.1.162.1/24' '10.1.162.2/24'
# node_2497-16509                        
echo "adding edge node_2497-16509"                        
sleep 1                        
funCreateV 'eth_16509' 'eth_2497' '42' '46' '10.1.164.1/24' '10.1.164.2/24'
# node_2497-4637                        
echo "adding edge node_2497-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_2497' '42' '49' '10.1.168.1/24' '10.1.168.2/24'
# node_4775-4637                        
echo "adding edge node_4775-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_4775' '44' '49' '10.2.140.2/24' '10.2.140.1/24'
# node_18403-4637                        
echo "adding edge node_18403-4637"                        
sleep 1                        
funCreateV 'eth_4637' 'eth_18403' '47' '49' '10.2.142.2/24' '10.2.142.1/24'