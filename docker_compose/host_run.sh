#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
model_name=$1
docker-compose down
rm -rf ./logs/*
docker rmi -f savop_bird_base
docker build . -t savop_bird_base
docker container rm $(docker container ls -aq)
# remove all stopped containers
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
# remove all images taged as <none>
docker-compose up -d --force-recreate  --remove-orphans
./topo.sh
docker-compose down
