#!/bin/sh
set -e

# These commands are from the docker website.
# This script is part of the server installation instructions
# described at http://blog.cyber-dojo.org/2016/07/running-your-own-cyber-dojo-web-server.html

ME=`whoami`
if [ "${ME}" != 'root' ]; then
  echo 'this must be run as root'
  exit
fi

echo 'installing docker'
# This currently installs docker 1.12.1
curl -sSL https://get.docker.com/ | sh

echo 'installing docker-compose 1.8.0'
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin
