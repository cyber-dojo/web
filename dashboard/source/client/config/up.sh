#!/usr/bin/env bash
set -Eeu

readonly PORT="${CYBER_DOJO_DASHBOARD_CLIENT_PORT}"
readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export RUBYOPT='-W2 --enable-frozen-string-literal'

puma \
  --port=${PORT} \
  --config=${MY_DIR}/puma.rb
