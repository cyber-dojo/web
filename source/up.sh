#!/usr/bin/env bash
set -Eeu

readonly PORT="${CYBER_DOJO_WEB_PORT}"
readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export CYBER_DOJO_RUNNER_CLASS=RunnerService
export CYBER_DOJO_SAVER_CLASS=SaverService

export RUBYOPT='-W2 --enable-frozen-string-literal'

puma \
  --port=${PORT} \
  --config=${MY_DIR}/config/puma.rb
