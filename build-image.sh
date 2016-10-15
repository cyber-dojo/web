#!/bin/sh
set -e

# A docker-client binary is installed *inside* the web image
# This creates a dependency on the docker-version installed
# on the host. Thus, the web Dockerfile accepts the docker-version
# to install as a parameter, and the built web image is tagged with
# this version number.
DOCKER_VERSION=${1:-1.12.2}

# the 'home' directory inside the web image. I don't expect
# this to change, it's parameterized to avoid duplication.
CYBER_DOJO_HOME=${2:-/usr/src/cyber-dojo}

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

context_dir=${my_dir}

docker build \
  --build-arg=CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
  --build-arg=DOCKER_VERSION=${DOCKER_VERSION} \
  --tag=cyberdojo/web:${DOCKER_VERSION} \
  --file=${context_dir}/Dockerfile \
  ${context_dir}
