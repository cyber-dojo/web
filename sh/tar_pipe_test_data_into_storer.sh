#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly STORER_CONTAINER=test-web-storer

echo "clearing out old ${STORER_CONTAINER}"
docker exec -it ${STORER_CONTAINER} sh -c 'rm -rf /usr/src/cyber-dojo/katas/*'

echo "filling old ${STORER_CONTAINER} with test data"
${SH_DIR}/insert_katas_test_data.sh ${STORER_CONTAINER}
