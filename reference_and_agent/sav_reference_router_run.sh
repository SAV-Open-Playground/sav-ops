# !/usr/bin/bash
# set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
bird -D ${FOLDER}/logs/bird.log -f
