#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

build_service_image()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
      build \
        "${1}"
}

build_service_image web

# Assuming we do not have any new web commits, web's latest commit
# sha will match the image tag inside versioner's .env file.
# This means we can tag to it and a [cyber-dojo up] call
# will use the tagged image.
docker tag cyberdojo/web:latest cyberdojo/web:${SHA:0:7}
