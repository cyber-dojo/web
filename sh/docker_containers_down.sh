#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  down \
  --remove-orphans
