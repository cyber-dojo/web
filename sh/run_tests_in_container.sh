#!/bin/bash -Eeu

#- - - - - - - - - - - - - - - - - - - -
# Copy saver-test-data into saver container
# Done here to ensure it always happens before tests are run.

readonly CONTAINER=test_web_saver
readonly SRC_PATH=${ROOT_DIR}/test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

run_tests_in_container()
{
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${CONTAINER} tar x -C ${DEST_PATH}

  #- - - - - - - - - - - - - - - - - - - -
  # Now docker exec in and run the tests
  local -r WEB_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "^test_web$")
  local -r SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
  local -r DST=${ROOT_DIR}/coverage/

  # Drop set -e because we want to get coverage stats out
  set +e
  docker exec --user nobody "${WEB_CID}" sh -c "cd /cyber-dojo/test && ./run.sh ${@:-}"
  readonly STATUS=$?
  mkdir -p "${DST}"
  docker cp "${SRC}/." "${DST}"
  return ${STATUS}
}
