# !/usr/bin/bash
# set -ex
sleep 3 # for the interface to be added
echo '10.0.9.1        savopkrill.com' >> /etc/hosts

# TODO: proced untill down finished
# TAL_GOOD=false
# while $TAL_GOOD
# do
#     RETURN_CODE=$(curl --write-out "%{http_code}\n" -k https://savopkrill:3000/testbed.tal >> /var/routinator/tals/krill.tal --output output.txt -silent)
#     echo $RETURN_CODE
#     if [ $RETURN_CODE -eq 200 ]; then
#     TAL_GOOD=true;
# done
# update-ca-certificates
mkdir /var/routinator/
mkdir /var/routinator/tals/
curl -k https://savopkrill.com:3000/testbed.tal >> /var/routinator/tals/krill.tal
routinator -c /etc/routinator/routinator.conf --rrdp-root-cert=/var/routinator/data/ca.pem --rrdp-root-cert=/var/routinator/data/web.pem -v -v server 
# routinator -c /etc/routinator/routinator.conf -v -v server 
