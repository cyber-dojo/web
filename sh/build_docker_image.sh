#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

. ${ROOT_DIR}/.env

docker-compose \
  --file ${ROOT_DIR}/docker-compose.yml \
  build
