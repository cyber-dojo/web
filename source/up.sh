#!/usr/bin/env bash
set -Eeu

# [1] https://github.com/docker/compose/issues/1393
# [1] http://stackoverflow.com/questions/35022428
readonly WEB_HOME=/cyber-dojo
rm -f ${WEB_HOME}/tmp/pids/server.pid # [1]

export CYBER_DOJO_RUNNER_CLASS=RunnerService
export CYBER_DOJO_SAVER_CLASS=SaverService

export RUBYOPT='-W2 --enable-frozen-string-literal'

rails server \
  --environment=production
