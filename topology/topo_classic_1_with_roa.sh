#!/usr/bin/bash
# remove folders created last time
rm -r /var/run/netns
mkdir /var/run/netns

funCreateV(){
    # para 1: the tag of src node, 
    # para 2: the tag of dst node
    # para 3: the IP addr of the local node interface 
    # para 4: the IP addr of the peer node interface    
    PID_L=$(sudo docker inspect -f '{{.State.Pid}}' $1)
    PID_P=$(sudo docker inspect -f '{{.State.Pid}}' $2)
    # echo "PID: $PID_P $PID_L"
    ln -sf /proc/$PID_L/ns/net /var/run/netns/$PID_L
    ln -sf /proc/$PID_P/ns/net /var/run/netns/$PID_P


    NET_L="eth_`echo ${1}|awk -F"_" '{ print $NF }'`_`echo ${2}|awk -F"_" '{ print $NF }'`"
    NET_P="eth_`echo ${2}|awk -F"_" '{ print $NF }'`_`echo ${1}|awk -F"_" '{ print $NF }'`"

    ip link add ${NET_L} type veth peer name ${NET_P}
    ip link set ${NET_L}  netns ${PID_L}
    ip link set ${NET_P}  netns ${PID_P}
    ip netns exec ${PID_L} ip addr flush ${NET_L}
    ip netns exec ${PID_L} ip addr add ${3} dev ${NET_L}
    ip netns exec ${PID_L} ip link set ${NET_L} up
    ip netns exec ${PID_P} ip addr flush ${NET_P}
    ip netns exec ${PID_P} ip addr add ${4} dev ${NET_P}
    ip netns exec ${PID_P} ip link set ${NET_P} up
    echo "edge ${NET_L} added"
}

funCreateV 'ca' 'roa' '10.0.9.1/24' '10.0.9.2/24'

funCreateV 'roa' 'ref_1' '10.0.8.1/24' '10.0.8.2/24'

# A-B
funCreateV 'ref_1' 'ref_2' '10.0.1.1/24' '10.0.1.2/24'

# A-C
funCreateV 'ref_1' 'ref_3' '10.0.2.1/24' '10.0.2.2/24'

# B-D
funCreateV 'ref_2' 'ref_4' '10.0.4.1/24' '10.0.4.2/24'

# B-E
funCreateV 'ref_2' 'ref_5' '10.0.5.1/24' '10.0.5.2/24'

# B-C
funCreateV 'ref_2' 'ref_3' '10.0.6.1/24' '10.0.6.2/24'

# D-E
funCreateV 'ref_4' 'ref_5' '10.0.7.1/24' '10.0.7.2/24'

let "TAL_GOOD=-1"
let "MAX=60"
while [ $TAL_GOOD -ne 0 ]
do
   docker exec -it ca curl -k https://localhost:3000/ta/ta.cer -o /var/krill/data/repo/rsync/current/ta.cer
   if [ $? -eq 0 ]; then
        TAL_GOOD=0;
        break;
   fi
   sleep 1
   let "MAX--"
   if [ $MAX -eq 0 ]; then
        echo "Can't connect to krill finally! Please check out system"
        exit -1
   fi
done

sleep 15
# wait for the containers to perform, you can change the value based 
# on your hardware and configurations
node_array=`docker ps|grep "savop_bird_base" | awk '{ print $NF }' | awk -F"_" '{ print $NF }' | sort | xargs`
FOLDER=$(cd "$(dirname "$0")";pwd)
for node_num in ${node_array[*]}
do
    echo "======================== ref_$node_num log========================"
    docker logs ref_${node_num}
    echo "======================== ref_$node_num FIB========================"
    docker exec -it ref_${node_num} route -n -F
    docker exec -it ref_${node_num} route -n -F >${FOLDER}/logs/${node_num}/router_table.txt 2>&1
    docker exec -it ref_${node_num} curl -s http://localhost:8888/sib_table/ >${FOLDER}/logs/${node_num}/sav_table.txt 2>&1
done
