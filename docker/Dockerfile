FROM savop_base

RUN mkdir -p /root/savop/
RUN mkdir -p /root/savop/logs
RUN touch /root/savop/logs/access.log
RUN touch /root/savop/logs/error.log

RUN mkdir -p /usr/local/var/run
COPY ./bird /usr/local/sbin/
COPY ./birdc /usr/local/sbin/
COPY ./birdcl /usr/local/sbin/

COPY ./extend_server/ /root/savop/extend_server/
COPY ./container_run.sh /root/savop/container_run.sh

WORKDIR /root/savop/
