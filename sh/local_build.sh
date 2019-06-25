#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

"${ROOT_DIR}/sh/build_docker_images.sh"
docker tag cyberdojo/web:latest cyberdojo/web:9999999
