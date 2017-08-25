#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. ${ROOT_DIR}/env_vars.sh

docker-compose --file ${ROOT_DIR}/docker-compose.yml build
