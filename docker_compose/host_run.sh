#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
model_name=$1
echo $1
docker compose down
rm -rf ./logs/*; mkdir ./logs
docker rmi -f savop_bird_base
docker build -f ./dockerfiles/reference_router . -t savop_bird_base
image_name="`grep "image: krill" rpki_infrastracture.yml |awk '{ print $2 }'`"
if [ "${image_name}" = "krill" ]
then
    #docker build -f ./dockerfiles/nlnetlabs_base . -t nlnetlabs_base
    #docker build -f ./dockerfiles/krill . -t krill
    rm -rf ./krill_data
    rm -rf ${FOLDER}/logs/krill.log 
    touch ${FOLDER}/logs/krill.log
    rm -rf ${FOLDER}/logs/rsync.log
    touch ${FOLDER}/logs/rsync.log
fi
image_name=`grep "image: routinator" rpki_infrastracture.yml |awk '{ print $2 }'`
if [ "${image_name}" = "routinator" ];then
    #docker build -f ./dockerfiles/routinator . -t routinator
    rm -rf ./routinator_data
    rm -rf ./logs/routinator.log
    touch ${FOLDER}/logs/routinator.log
fi
docker container rm -f $(docker container ls -aq)
# remove all stopped containers
# docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
# remove all images taged as <none>
if [ `expr match ${model_name} .*with_roa` -gt 0 ];then
    docker-compose -f ./rpki_infrastracture.yml up -d --force-recreate
fi
docker compose up -d --force-recreate
sleep 3
bash topo.sh
#docker compose down
