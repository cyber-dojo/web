#!/bin/bash
set -e

storer_cid=`docker ps --all --quiet --filter "name=cyber-dojo-storer"`
docker exec ${storer_cid} sh -c "rm -rf /tmp/cyber-dojo/katas/*"

web_cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${web_cid} sh -c "cd test && ./run.sh ${*}"

# copy coverage stats out of container
my_dir="$( cd "$( dirname "${0}" )" && pwd )"
mkdir -p ${my_dir}/coverage

src=${web_cid}:/tmp/cyber-dojo/coverage/.
dst=${my_dir}/coverage/
docker cp ${src} ${dst}
