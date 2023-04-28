#!/usr/bin/bash
set -ex
sys_version=`cat /etc/lsb-release | grep DISTRIB_DESCRIPTION | awk -F= '{gsub("\"", ""); print $2 }'`
# limite os version

# install docker
apt-get -y update
# apt-get remove docker docker-engine docker.io containerd runc -y
apt-get install ca-certificates curl gnupg -y
sudo install -m 755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# bird env
apt-get -y update
apt-get -y install build-essential flex bison autoconf ncurses-dev libreadline-dev libssh-gcrypt-dev\
	linuxdoc-tools-latex texlive-latex-extra opensp docbook-xsl xsltproc git dpkg-dev debhelper \
	apt-utils quilt python3 python3-pip python3-setuptools iputils-ping net-tools vim traceroute \
        sqlite3 iptables expect

pip install Flask gunicorn blinker flask-sqlalchemy netaddr -i https://pypi.mirrors.ustc.edu.cn/simple/
docker build -f ./dockerfiles/savop_base . -t savop_base
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

#Rust env and compile 
apt -y install curl build-essential libssl-dev openssl pkg-config git
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cd /root
git clone https://github.com/NLnetLabs/krill.git
cd /root/krill
git checkout -b v0.12.3 v0.12.3
cargo build --features aspa --locked
