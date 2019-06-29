#!/bin/bash
# shellcheck source=/dev/null
set -e

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - - -

wait_until_ready()
{
  local -r name="test-web-${1}"
  local -r port="${2}"
  local -r max_tries=20
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if $(curl_cmd ${port} ready?) ; then
      echo 'OK'
      return
    else
      sleep 0.2
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

curl_cmd()
{
  local -r port="${1}"
  local -r path="${2}"
  local -r cmd="curl --output /tmp/curl-probe --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f /tmp/curl-probe
  if ${cmd} && [ "$(cat /tmp/curl-probe)" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - -

wait_until_running()
{
  local n=20
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q "^${1}$" ; then
      return
    else
      sleep 0.1
    fi
  done
  echo "${1} not up after 5 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env' > /tmp/versioner.web.env
set -a
. /tmp/versioner.web.env
set +a
export CYBER_DOJO_LANGUAGES=cyberdojo/languages-all:d996783
export CYBER_DOJO_DIFFER_TAG=${CYBER_DOJO_DIFFER_SHA:0:7}
export CYBER_DOJO_MAPPER_TAG=${CYBER_DOJO_MAPPER_SHA:0:7}
export CYBER_DOJO_RAGGER_TAG=${CYBER_DOJO_RAGGER_SHA:0:7}
export CYBER_DOJO_RUNNER_TAG=${CYBER_DOJO_RUNNER_SHA:0:7}
export CYBER_DOJO_SAVER_TAG=${CYBER_DOJO_SAVER_SHA:0:7}
export CYBER_DOJO_ZIPPER_TAG=${CYBER_DOJO_ZIPPER_SHA:0:7}
export CYBER_DOJO_VERSIONER_TAG=${CYBER_DOJO_VERSIONER_TAG:-latest}

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_until_running 'test-web'

wait_until_ready    'custom' 4526
wait_until_ready 'exercises' 4525
wait_until_ready 'languages' 4524

wait_until_ready 'runner'  4597
wait_until_ready 'differ'  4567
wait_until_ready 'saver'   4537
wait_until_ready 'mapper'  4547
wait_until_ready 'ragger'  5537

#wait_until_ready 'zipper'  4587
