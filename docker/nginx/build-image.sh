#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
context_dir=${my_dir}

docker build \
  --tag=cyberdojo/${PWD##*/} \
  --file=${context_dir}/Dockerfile \
  ${context_dir}
