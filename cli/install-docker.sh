#!/bin/sh
set -e

# These commands are from the docker website.
# This script is part of the server installation instructions
# described at http://blog.cyber-dojo.org/2016/07/running-your-own-cyber-dojo-web-server.html

echo 'installing docker 1.11.2'
curl -L https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz > docker-1.11.2.tgz
tar -xvzf docker-1.11.2.tgz
rm docker-1.11.2.tgz
mv docker/* /usr/bin/
rmdir docker

echo 'installing docker-machine 0.7.0'
curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` > docker-machine
mv docker-machine /usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine

echo 'installing docker-compose 1.7.1'
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > docker-compose
mv docker-compose /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
