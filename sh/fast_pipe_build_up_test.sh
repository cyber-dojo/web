#!/bin/bash
docker rm test-web --force
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
export TAG=${SHA:0:7}

"${SH_DIR}/build_docker_images.sh"

docker run \
  --detach \
  --name test-web \
  --user nobody \
  cyberdojo/web:latest

"${SH_DIR}/run_tests_in_container.sh" "$@"
docker rm test-web --force
