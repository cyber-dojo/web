#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

ID="${1}"      # eg 3Ef6a2

saver_port() { echo "${CYBER_DOJO_SAVER_PORT}"; }

curl_json()
{
  curl  \
    --data '{"id":"'${ID}'"}' \
    --fail \
    --header 'Content-type: application/json' \
    --request GET \
    --silent \
    --verbose \
      "http://localhost:$(saver_port)/kata_events" | jq .
}

curl_json 
