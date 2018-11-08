#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=cyber-dojo-storer

echo "clearing out old ${STORER_CONTAINER}"
docker exec -it ${STORER_CONTAINER} sh -c 'rm -rf /usr/src/cyber-dojo/katas/*'

echo "filling old ${STORER_CONTAINER} will test data"
${SH_DIR}/insert_katas_test_data.sh ${STORER_CONTAINER}

echo "clearing out new saver"
docker-machine ssh default 'cd /tmp/id-map && sudo rm -rf * && sudo chown -R 19664 .'
docker-machine ssh default 'cd /tmp/groups && sudo rm -rf * && sudo chown -R 19663 .'
docker-machine ssh default 'cd /tmp/katas  && sudo rm -rf * && sudo chown -R 19663 .'
