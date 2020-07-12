#!/bin/bash

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME:-}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - - -

wait_until_ready()
{
  local -r name="test_web_${1}"
  local -r port="${2}"
  local -r max_tries=60
  echo -n "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    echo -n '.'
    if ready ${port} ; then
      echo 'OK'
      return
    else
      sleep 0.2
    fi
  done
  echo 'FAIL'
  echo "${name} not ready after ${max_tries} tries"
  if [ -f "$(ready_filename)" ]; then
    echo "$(cat "$(ready_filename)")"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - -

ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r curl_cmd="curl --output $(ready_filename) --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "$(ready_filename)"
  if ${curl_cmd} && [ "$(cat "$(ready_filename)")" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - -
ready_filename()
{
  echo /tmp/curl-web-ready-output
}
