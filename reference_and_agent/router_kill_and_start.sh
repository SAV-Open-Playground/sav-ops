# !/usr/bin/bash
# set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
ACCESS_LOGFILE=${FOLDER}/logs/access.log
ERROR_LOGFILE=${FOLDER}/logs/error.log
BIRD_LOGFILE=${FOLDER}/logs/bird.log
CDDIR=${FOLDER}/sav-agent/
GUNICORN_COUNT=`ps aux|grep gunicorn|grep -v grep|wc -l`
BIRD_COUNT=`ps aux|grep bird|grep -v grep|wc -l`
QUIC_COUNT=`ps aux |grep quic_server|grep -v grep|wc -l`
START_GUNICORN_COMMAND="gunicorn -D --chdir ${CDDIR} -b 0.0.0.0:8888 server:app --timeout 0 --workers 1 --access-logfile ${ACCESS_LOGFILE} --error-logfile ${ERROR_LOGFILE} --log-level debug --worker-connections 5"
if [ ${GUNICORN_COUNT} -gt 0 ];then
    ps aux|grep gunicorn|grep -v grep|awk '{ print $2 }'| xargs kill -9
fi

if [ ${BIRD_COUNT} -gt 0 ];then
    ps aux|grep bird|grep -v grep|awk '{ print $2 }'| xargs kill -9
fi

if [ ${QUIC_COUNT} -gt 0 ];then
    ps aux|grep quic_server|grep -v grep|awk '{ print $2 }'| xargs kill -9
fi

if [ "$1" == "stop" ]; then
    exit 0
fi

rm -rf ${ACCESS_LOGFILE}
rm -rf ${ERROR_LOGFILE}
rm -rf ${BIRD_LOGFILE}
rm -rf ${FOLDER}/logs/server.log

#nohup python3 ${CDDIR}quic_server.py &
#nohup python3 /root/savop/sav-agent/quic_server.py > /dev/null 2>&1 &
if [ ${GUNICORN_COUNT} -eq 0 ];then
    eval ${START_GUNICORN_COMMAND}
fi
sleep 3
while [ ! -f ${ACCESS_LOGFILE} ] || [ ! -f ${ERROR_LOGFILE} ]
do
    ps aux|grep gunicorn|grep -v grep|awk '{ print $2 }'| xargs kill -9
    eval ${START_GUNICORN_COMMAND} 
done
sleep 3
bird -D ${BIRD_LOGFILE}
