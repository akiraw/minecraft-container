#! /bin/bash

# this script is intended to be run as sudo

apt-get update

apt-get install -y apt-transport-https ca-certificates

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get purge lxc-docker
apt-cache policy docker-engine

apt-get update
apt-get install -y --no-install-recommends linux-image-extra-$(uname -r)

apt-get install -y apparmor

apt-get update
apt-get install -y docker-engine

service docker start
docker run hello-world

groupadd docker
usermod -aG docker ubuntu
