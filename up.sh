#!/bin/sh
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${ROOT_DIR}/.env

# See https://github.com/docker/compose/issues/1393
# See http://stackoverflow.com/questions/35022428
rm -f ${WEB_HOME}/tmp/pids/server.pid

export CYBER_DOJO_DIFFER_CLASS=DifferService
export CYBER_DOJO_RUNNER_CLASS=RunnerService
export CYBER_DOJO_STARTER_CLASS=StarterService
export CYBER_DOJO_STORER_CLASS=StorerService
export CYBER_DOJO_ZIPPER_CLASS=ZipperService
export CYBER_DOJO_HTTP_CLASS=Http

rails server \
  --environment=production