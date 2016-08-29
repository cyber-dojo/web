#!/bin/sh
set -e

DOCKER_VERSION=${1:-1.12.1}

docker push cyberdojo/${PWD##*/}:${DOCKER_VERSION}
