#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
model_name=$1
docker compose down
rm -rf ./logs/*; mkdir ./logs
docker rmi -f savop_bird_base
docker build -f ./dockerfiles/reference_router . -t savop_bird_base
image_name="`grep "image: krill" docker-compose.yml |awk '{ print $2 }'`"
if [ "${image_name}" = "krill" ]
then
    docker build -f ./dockerfiles/nlnetlabs_base . -t nlnetlabs_base
    docker build -f ./dockerfiles/krill . -t krill
    rm -rf ./krill_data
    rm -rf ${FOLDER}/logs/krill.log 
    echo "" > ${FOLDER}/logs/krill.log
    rm -rf ${FOLDER}/logs/rsync.log
    echo "" > ${FOLDER}/logs/rsync.log
fi
image_name=`grep "image: routinator" docker-compose.yml |awk '{ print $2 }'`
if [ "${image_name}" = "routinator" ];then
    docker build -f ./dockerfiles/routinator . -t routinator
    rm -rf ./routinator_data
    rm -rf ./logs/routinator.log
    echo "" > ./logs/routinator.log
fi
docker container rm -f $(docker container ls -aq)
# remove all stopped containers
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
# remove all images taged as <none>
docker compose up -d --force-recreate  --remove-orphans
sleep 3
bash ./topo.sh
#docker compose down
