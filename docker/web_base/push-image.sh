#!/bin/sh
set -e

DOCKER_VERSION=${1:-1.11.2}

docker push cyberdojo/${PWD##*/}:${DOCKER_VERSION}
