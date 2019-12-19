#!/bin/bash
# Don't do [set -e] because we want to get coverage stats out

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly WEB_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "^test-web$")

readonly SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
readonly DST=${ROOT_DIR}/coverage/

docker exec "${WEB_CID}" sh -c "cd /cyber-dojo/test && ./run.sh ${*}"
readonly STATUS=$?
mkdir -p "${DST}"
docker cp "${SRC}/." "${DST}"
exit ${STATUS}
