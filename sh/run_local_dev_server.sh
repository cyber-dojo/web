#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

cd ${ROOT_DIR}/sh
./build_docker_images.sh

WEB_SHA=$(printf '9%.0s' {1..40})
docker tag cyberdojo/web:latest cyberdojo/web:${WEB_SHA:0:7}

cd ${ROOT_DIR}/../versioner
echo "CYBER_DOJO_WEB_SHA=${WEB_SHA}" >> ./.env
./sh/build_docker_images.sh

cd ${ROOT_DIR}/../commander
unset COMMANDER_SHA
./cyber-dojo up
