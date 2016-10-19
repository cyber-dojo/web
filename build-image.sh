#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_version=${1:-1.12.2}
cyber_dojo_home=${2:-/usr/src/cyber-dojo}

context_dir=${my_dir}

docker build \
  --build-arg=CYBER_DOJO_HOME=${cyber_dojo_home} \
  --build-arg=DOCKER_VERSION=${docker_version} \
  --tag=cyberdojo/web:${docker_version} \
  --file=${context_dir}/Dockerfile \
  ${context_dir}
