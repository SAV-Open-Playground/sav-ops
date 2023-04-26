#!/usr/bin/bash
set -ex
sys_version=`cat /etc/lsb-release | grep DISTRIB_DESCRIPTION | awk -F= '{gsub("\"", ""); print $2 }'`
# limite os version

apt-get -y update
apt-get -y install build-essential flex bison autoconf ncurses-dev libreadline-dev libssh-gcrypt-dev\
	linuxdoc-tools-latex texlive-latex-extra opensp docbook-xsl xsltproc git dpkg-dev debhelper \
	apt-utils quilt python3 python3-pip python3-setuptools iputils-ping net-tools vim traceroute \
        sqlite3 iptables expect

pip install Flask gunicorn blinker flask-sqlalchemy netaddr -i https://pypi.mirrors.ustc.edu.cn/simple/
docker build -f ./Dockerfile_SAVOP_Base . -t savop_base
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
