#!/bin/bash
# shellcheck source=/dev/null
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

. "${ROOT_DIR}/.env"

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build
