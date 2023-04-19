#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
if [ -z "$var" ];then
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

echo "compile bird"
cd ../sav-reference-router
rm -f  "./bird" "./birdc" "./birdcl"
autoconf
./configure
make
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
if [ ! -d "${FOLDER}/extend_server" ];then
  mkdir ${FOLDER}/build/extend_server
fi
cp -r *.py ${FOLDER}/build/extend_server
cp -r ${FOLDER}/configs/conf_${model_name} ${FOLDER}/build/configs 
cp ${FOLDER}/docker_compose/host_run.sh ${FOLDER}/build/host_run.sh
cp ${FOLDER}/docker_compose/docker_compose_${model_name}.yml ${FOLDER}/build/compose.yml
cp ${FOLDER}/dockerfiles/reference_router ${FOLDER}/build/reference_router
cp ${FOLDER}/topology/topo_${model_name}.sh ${FOLDER}/build/topo.sh
cp ${FOLDER}/reference_and_agent/container_run.sh  ${FOLDER}/build/container_run.sh
cp ${FOLDER}/dockerfiles/traffic_generator ${FOLDER}/build/traffic_generator
cp -r ${FOLDER}/network_test ${FOLDER}/build/
echo "complile bird over"
cd  ../sav-start/build
./host_run.sh
exit 0

