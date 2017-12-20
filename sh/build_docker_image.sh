#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. ${ROOT_DIR}/sh/env_vars.sh

docker-compose \
  --file ${ROOT_DIR}/docker-compose.yml \
  build
