#!/bin/bash
#Don't do [set -e] because we want to get coverage stats out

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly WEB_CID=$(docker ps --all --quiet --filter "name=test-cyber-dojo-web")
readonly SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
readonly DST=${ROOT_DIR}/coverage/

docker exec "${WEB_CID}" sh -c "cd test && ./run.sh ${*}"
readonly STATUS=$?
mkdir -p "${DST}"
docker cp "${SRC}/." "${DST}"
exit ${STATUS}