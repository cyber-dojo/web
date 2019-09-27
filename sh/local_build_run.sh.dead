#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

"${ROOT_DIR}/sh/build_docker_images.sh"
WEB_SHA=$(printf '9%.0s' {1..40})
docker tag cyberdojo/web:latest cyberdojo/web:${WEB_SHA:0:7}
${ROOT_DIR}/../commander/cyber-dojo up
