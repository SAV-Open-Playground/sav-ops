# !/usr/bin/bash
# set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
ACCESS_LOGFILE=${FOLDER}/logs/access.log
ERROR_LOGFILE=${FOLDER}/logs/error.log
CDDIR=${FOLDER}/sav-agent/
GUNICORN_COUNT=`ps aux|grep gunicorn|grep -v grep|wc -l`
START_GUNICORN_COMMAND="gunicorn -D --chdir ${CDDIR} -b 0.0.0.0:8888 server:app --workers 1 --access-logfile ${ACCESS_LOGFILE} --error-logfile ${ERROR_LOGFILE} --log-level debug"
if [ ${GUNICORN_COUNT} -gt 0 ];then
    ps aux|grep gunicorn|grep -v grep|awk '{ print $2 }'| xargs kill -9
    eval ${START_GUNICORN_COMMAND}
fi
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
