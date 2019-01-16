#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# You cannot docker cp to a tmpfs, you have to tar-pipe instead...

readonly CONTAINER=test-web-saver
readonly SRC_PATH=${MY_DIR}/../test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

cd ${SRC_PATH} \
  && tar -cv . \
  | docker exec -i ${CONTAINER} tar x -C ${DEST_PATH}
