#!/usr/bin/bash
#set -ex
sleep 7
echo '10.10.0.2        savopkrill.com' >> /etc/hosts
let "TAL_GOOD=-1"
let "MAX=60"
update-ca-certificates
mkdir /var/routinator/tals
while [ $TAL_GOOD -ne 0 ]
do
   curl -k https://savopkrill.com:3000/testbed.tal > /var/routinator/tals/krill.tal
   if [ $? -eq 0 ]; then
	TAL_GOOD=0;
	break;
   fi
   sleep 1
   let "MAX--"
   if [ $MAX -eq 0 ]; then
	echo "Can't connect to krill finally! Please check out system"
        exit -1
   fi
done

routinator -c /etc/routinator/routinator.conf --rrdp-root-cert=/var/routinator/data/ca.pem --rrdp-root-cert=/var/routinator/data/web.pem -v -v server

