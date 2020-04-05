#!/bin/bash
set -e

#- - - - - - - - - - - - - - - - - - - -
# Copy saver-test-data into saver container
# Done here to ensure it always happens before tests are run
# eg after a sh/dev_server_web_restart.sh

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
readonly CONTAINER=test-web-saver
readonly SRC_PATH=${ROOT_DIR}/test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

# You cannot docker cp to a tmpfs, so tar-piping instead...
cd ${SRC_PATH} \
  && tar -c . \
  | docker exec -i ${CONTAINER} tar x -C ${DEST_PATH}

#- - - - - - - - - - - - - - - - - - - -
# Now docker exec in and run the tests
readonly WEB_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "^test-web$")
readonly SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
readonly DST=${ROOT_DIR}/coverage/

# Drop set -e because we want to get coverage stats out
set +e
docker exec --user nobody "${WEB_CID}" sh -c "cd /cyber-dojo/test && ./run.sh ${*}"
readonly STATUS=$?
mkdir -p "${DST}"
docker cp "${SRC}/." "${DST}"
exit ${STATUS}
