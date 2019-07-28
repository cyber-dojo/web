#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build

# Assuming we do not have any new web commits, web's latest commit
# sha will match the image tag inside versioner's .env file.
# This means we can tag to it and a [cyber-dojo up] call
# will use the tagged images.
readonly SHA=$(docker run --rm cyberdojo/web:latest sh -c 'echo -n ${SHA}')
readonly TAG=${SHA:0:7}
docker tag cyberdojo/web:latest cyberdojo/web:${TAG}

docker system prune --force > /dev/null 2>&1
