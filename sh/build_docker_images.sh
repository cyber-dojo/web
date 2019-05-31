#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build

docker system prune --force > /dev/null 2>&1
