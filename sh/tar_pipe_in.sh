#!/bin/bash

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly STORER_CONTAINER=cyber-dojo-storer

echo "clearing out old ${STORER_CONTAINER}"
docker exec -it ${STORER_CONTAINER} sh -c 'rm -rf /usr/src/cyber-dojo/katas/*'

echo "filling old ${STORER_CONTAINER} will test data"
${ROOT_DIR}/../porter/test/storer_katas/old/tar_pipe_in.sh ${STORER_CONTAINER}
${ROOT_DIR}/../porter/test/storer_katas/dup/tar_pipe_in.sh ${STORER_CONTAINER}

echo "clearing out new saver"
docker-machine ssh default sh -c 'cd /tmp/id-map && sudo rm -rf *'
docker-machine ssh default sh -c 'cd /tmp/groups && sudo rm -rf *'
docker-machine ssh default sh -c 'cd /tmp/katas  && sudo rm -rf *'
