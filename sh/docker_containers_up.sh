#!/bin/bash
# shellcheck source=/dev/null
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

# - - - - - - - - - - - - - - - - - - - - -

wait_until_running()
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

wait_until_ready()
{
  local name="${1}"
  local port="${2}"
  local method="${3:-sha}"
  local max_tries=10
  local cmd="curl --silent --fail --data '{}' -X GET http://localhost:${port}/${method}"
  cmd+=" > /dev/null 2>&1"

  if [ ! -z ${DOCKER_MACHINE_NAME} ]; then
    cmd="docker-machine ssh ${DOCKER_MACHINE_NAME} ${cmd}"
  fi
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if eval ${cmd} ; then
      echo 'OK'
      return
    else
      sleep 0.1
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_until_running 'test-web'

wait_until_ready    'custom' 4527 ready?
wait_until_ready 'exercises' 4526 ready?
wait_until_ready 'languages' 4525 ready?

wait_until_ready 'runner'  4597
wait_until_ready 'differ'  4567
wait_until_ready 'saver'   4537 ready?
wait_until_ready 'mapper'  4547 ready?

#wait_until_ready 'zipper'  4587
