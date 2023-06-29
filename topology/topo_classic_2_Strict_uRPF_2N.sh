#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

node_array=("1" "2" "3" "4" "5")
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
    # para 3: local node in number,1
    # para 4: peer node in number,2
    # para 5: the IP addr of the local node interface 
    # para 6: the IP addr of the peer node interface    
    PID_L=${pid_array[$3-1]}
    PID_P=${pid_array[$4-1]}
    NET_L="eth_$1_$2"
    NET_P="eth_$2_$1"
    echo "adding edge eth_$1_$2"
    # echo $PID_L $PID_P $NET_L $NET_P ${5} ${6}
    ip link add ${NET_L} type veth peer name ${NET_P}
    ip link set ${NET_L}  netns ${PID_L}
    ip link set ${NET_P}  netns ${PID_P}
    ip netns exec ${PID_L} ip addr flush ${NET_L}
    ip netns exec ${PID_L} ip addr add ${5} dev ${NET_L}
    ip netns exec ${PID_L} ip link set ${NET_L} up
    ip netns exec ${PID_P} ip addr flush ${NET_P}
    ip netns exec ${PID_P} ip addr add ${6} dev ${NET_P}
    ip netns exec ${PID_P} ip link set ${NET_P} up
}

# A-B
funCreateV '1' '2' 1 2 '10.0.1.1/24' '10.0.1.2/24'

# A-C
funCreateV '1' '4' 1 4 '10.0.2.1/24' '10.0.2.2/24'

# B-D
funCreateV '2' '4' 2 4 '10.0.3.1/24' '10.0.3.2/24'

# B-E
funCreateV '3' '4' 3 4 '10.0.4.2/24' '10.0.4.1/24'

# B-C
funCreateV '3' '5' 3 5 '10.0.5.2/24' '10.0.5.1/24'

# D-E
funCreateV '4' '5' 4 5 '10.0.6.1/24' '10.0.6.2/24'

sleep 15
# wait for the containers to perform, you can change the value based 
# on your hardware and configurations

FOLDER=$(cd "$(dirname "$0")";pwd)
for node_num in ${node_array[*]}
do
    echo "======================== node_$node_num log========================"
    docker logs node_${node_num}
    echo "======================== node_$node_num FIB========================"
    docker exec -it node_${node_num} route -n -F
    docker exec -it node_${node_num} route -n -F >${FOLDER}/logs/${node_num}/router_table.txt 2>&1
    docker exec -it node_${node_num} curl -s http://localhost:8888/sib_table/ >${FOLDER}/logs/${node_num}/sav_table.txt 2>&1
done
