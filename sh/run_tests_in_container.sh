#!/bin/bash
#Don't do [set -e] because we want to get coverage stats out

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

storer_cid=`docker ps --all --quiet --filter "name=cyber-dojo-storer"`
docker exec ${storer_cid} sh -c "rm -rf /tmp/cyber-dojo/katas/*"

web_cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${web_cid} sh -c "cd test && ./run.sh ${*}"
status=$?

# copy coverage stats out of container
mkdir -p ${ROOT_DIR}/coverage

src=${web_cid}:/tmp/cyber-dojo/coverage/.
dst=${ROOT_DIR}/coverage/
docker cp ${src} ${dst}

exit ${status}