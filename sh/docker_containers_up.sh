#!/bin/bash
# shellcheck source=/dev/null
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - -

wait_till_up()
{
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q "^${1}$" ; then
      return
    else
      sleep 0.5
    fi
  done
  echo "${1} not up after 5 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_till_up 'test-web'
wait_till_up 'test-web-starter'
wait_till_up 'test-web-runner'
wait_till_up 'test-web-saver'
wait_till_up 'test-web-differ'
wait_till_up 'test-web-zipper'
