# !/usr/bin/bash
# set -ex
update-ca-certificates
rsync --daemon
python3 /var/krill/add_info.py /var/krill/roas.json /var/krill/aspas.json &
/root/.cargo/bin/krill -c /var/krill/data/krill.conf 
