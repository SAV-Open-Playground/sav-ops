# !/usr/bin/bash
# set -ex
rsync --daemon
krill -c /var/krill/data/krill.conf

