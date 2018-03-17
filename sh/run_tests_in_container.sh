#!/bin/bash
#Don't do [set -e] because we want to get coverage stats out

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

readonly WEB_CID=$(docker ps --all --quiet --filter "name=test_cyber-dojo-web")
docker exec "${WEB_CID}" sh -c "cd test && ./run.sh ${*}"
readonly STATUS=$?

# copy coverage stats out of container
mkdir -p "${ROOT_DIR}/coverage"

readonly SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
readonly DST=${ROOT_DIR}/coverage/

docker cp "${SRC}/." "${DST}"

exit ${STATUS}