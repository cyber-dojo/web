#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
cyber_dojo_home=${2:-/usr/src/cyber-dojo}

context_dir=${my_dir}

docker build \
  --build-arg=CYBER_DOJO_HOME=${cyber_dojo_home} \
  --tag=cyberdojo/web \
  --file=${context_dir}/Dockerfile \
  ${context_dir}
