#!/bin/bash
set -e

cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"

# copy coverage stats out of container
my_dir="$( cd "$( dirname "${0}" )" && pwd )"
mkdir -p ${my_dir}/coverage

src=${cid}:/tmp/cyber-dojo/coverage/.
dst=${my_dir}/coverage/
docker cp ${src} ${dst}
