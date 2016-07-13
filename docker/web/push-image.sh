#!/bin/sh
set -e

DOCKER_VERSION=${1:-1.11.2}

docker push cyberdojo/web:${DOCKER_VERSION}
