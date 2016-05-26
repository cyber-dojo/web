#!/bin/sh
set -e

# the 'home' directory inside the web image. I don't expect
# this to change, it's parameterized to avoid duplication.
CYBER_DOJO_HOME=${1:-/usr/src/cyber-dojo}

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

CONTEXT_DIR=${MY_DIR}

docker build \
  --build-arg=CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
  --tag=cyberdojofoundation/default_exercises \
  --file=${CONTEXT_DIR}/Dockerfile \
  ${CONTEXT_DIR}

