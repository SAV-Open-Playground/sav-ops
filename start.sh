#!/usr/bin/bash
start=$(date +%s)
set -ex
sysctl -w net.ipv4.conf.default.rp_filter=0 ;
FOLDER=$(cd "$(dirname "$0")";pwd)
if [ -z "$1" ];then
	model_name="classic_1"
else
	model_name=$1
fi
echo ${FOLDER}
echo "start to ${model_name} net mode" 

cd ${FOLDER}
if [ ! -d "./build" ];then
  echo "create compile directory"
  mkdir ./build
else
  echo "create compile directory"
  rm -rf ./build && mkdir ./build
fi

cd ../sav-reference-router
if [ -n "$2" ];then
	echo "compiling bird"
  #rm -f  "./bird" "./birdc" "./birdcl"
  #autoconf
  #./configure
  make
else
  echo "skip bird compiling"
fi
if [ -f "./bird" ] && [ -f "./birdc" ] && [ -f "./birdcl" ];then
  echo "bird birdc birdcl are ready"
else
  echo "please check if bird birdc birdcl eixts"
  exit -1
fi
cp ./bird ${FOLDER}/build/
cp ./birdc ${FOLDER}/build/
cp ./birdcl ${FOLDER}/build/ 
cd ../sav-agent
if [ ! -d "${FOLDER}/sav-agent" ];then
  mkdir ${FOLDER}/build/sav-agent
fi
cp -r *.py ${FOLDER}/build/sav-agent
# cp -r trafficTools ${FOLDER}/build/sav-agent/
# cp -r ${FOLDER}/traffic_tools ${FOLDER}/build/sav-agent/trafficTools
cp -r ${FOLDER}/configs/conf_${model_name} ${FOLDER}/build/configs
cp -r ${FOLDER}/certification_authority/node_${model_name} ${FOLDER}/build/nodes
cp -r ${FOLDER}/certification_authority/ca ${FOLDER}/build/ca
if [ `expr match ${model_name} .*with_roa` -gt 0 ];then 
  cp -r ${FOLDER}/configs/conf_roa/krill ${FOLDER}/build/configs/
  cp ${FOLDER}/configs/conf_roa/routinator.conf ${FOLDER}/build/configs/
  #cd ${FOLDER}/build/configs/krill/keys && ./key.sh && cd ${FOLDER}
  #if [ ! -d "${FOLDER}/build/krill" ];then
  #    mkdir ${FOLDER}/build/krill
  #    cp /root/krill/target/debug/krill ${FOLDER}/build/krill/
  #    cp /root/krill/target/debug/krillc ${FOLDER}/build/krill/
  #    cp /root/krill/target/debug/krillup ${FOLDER}/build/krill/
  #fi
  cp ${FOLDER}/rpki/krill.sh  ${FOLDER}/build/krill.sh
  cp ${FOLDER}/rpki/add_info.py  ${FOLDER}/build/add_info.py
  cp ${FOLDER}/rpki/routinator.sh  ${FOLDER}/build/routinator.sh
  cp ${FOLDER}/docker_compose/rpki_infrastracture.yml  ${FOLDER}/build/rpki_infrastracture.yml
fi
cp ${FOLDER}/docker_compose/host_run.sh ${FOLDER}/build/host_run.sh
cp ${FOLDER}/docker_compose/docker_compose_${model_name}.yml ${FOLDER}/build/docker-compose.yml
cp -r ${FOLDER}/dockerfiles ${FOLDER}/build/
cp ${FOLDER}/topology/topo_${model_name}.sh ${FOLDER}/build/topo.sh
cp ${FOLDER}/reference_and_agent/container_run.sh  ${FOLDER}/build/container_run.sh
cp ${FOLDER}/reference_and_agent/router_kill_and_start.sh  ${FOLDER}/build/router_kill_and_start.sh
cp -r ${FOLDER}/network_test ${FOLDER}/build/
echo "complile bird over"
cd  ${FOLDER}/build
bash host_run.sh $model_name
end=$(date +%s)
take=$(( end - start ))
echo "Time taken to run sav_simulate is ${take} seconds."
cat /root/sav_simulate/savop_back/data/NSDI/signal/signal_100.txt > /root/sav_simulate/sav-start/build/signal/signal.txt
exit 0

