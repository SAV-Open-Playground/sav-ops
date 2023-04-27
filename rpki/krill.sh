# !/usr/bin/bash
# set -ex
update-ca-certificates
rsync --daemon
/root/.cargo/bin/krill -c /var/krill/data/krill.conf

