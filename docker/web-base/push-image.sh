#!/bin/sh
set -e

DOCKER_VERSION=${1:-1.12.0}

docker push cyberdojo/${PWD##*/}:${DOCKER_VERSION}
