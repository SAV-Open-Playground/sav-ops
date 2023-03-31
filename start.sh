#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
if [ -z "$var" ];then
	model_name="classic_1"
else
	model_name=$1
fi
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
cp ./bird ../sav-start/build/
cp ./birdc ../sav-start/build/
cp ./birdcl ../sav-start/build/ 
cd ../sav-agent
cp -r extend_server ../sav-start/build/
cp -r ../sav-start/configs/conf_${model_name} ../sav-start/build/configs 
cp ../sav-start/docker_compose/host_run.sh ../sav-start/build/host_run.sh
cp ../sav-start/docker_compose/docker_compose_${model_name}.yml ../sav-start/build/compose.yml
cp ../sav-start/docker/Dockerfile ../sav-start/build/Dockerfile
cp ../sav-start/topology/topo_${model_name}.sh ../sav-start/build/topo.sh
cp ../sav-start/reference_and_agent/container_run.sh  ../sav-start/build/container_run.sh 
echo "complile bird over"
cd  ../sav-start/build
./host_run.sh
exit 0

