#!/bin/bash
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

readonly READY_FILENAME='/tmp/curl-ready-output'

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
  if [ -f "${READY_FILENAME}" ]; then
    echo "$(cat "${READY_FILENAME}")"
  fi
  docker logs ${name}
  exit 1
}

# - - - - - - - - - - - - - - - - - - -

ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r curl_cmd="curl --output ${READY_FILENAME} --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "${READY_FILENAME}"
  if ${curl_cmd} && [ "$(cat "${READY_FILENAME}")" = '{"ready?":true}' ]; then
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
  echo "${1} not up after 2 seconds"
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - -
on_ci_pull_dependent_language_start_point_image()
{
  # Pull images to avoid potential timeouts when using the real runner.
  if on_ci; then
    # Get ruby_mini_test image-name from languages_start_points service
    # Output after the grep is
    #      "cyberdojofoundation/ruby_mini_test:0641114",
    # o) xargs strips leading whitespace and double quotes
    #      cyberdojofoundation/ruby_mini_test:0641114,
    # o) ${X%?} strips trailing comma
    #      cyberdojofoundation/ruby_mini_test:0641114
    local -r raw=$(curl --silent ${IP_ADDRESS}:4524/image_names | jq '.' | grep ruby_mini_test | xargs)
    local -r image_name="${raw%?}"
    docker pull "${image_name}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - -
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export NO_PROMETHEUS=true

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  -d \
  --force-recreate

wait_until_ready custom_start_points    4526
wait_until_ready exercises_start_points 4525
wait_until_ready languages_start_points 4524

wait_until_ready runner    4597
wait_until_ready differ    4567
wait_until_ready saver     4537
#wait_until_ready zipper    4587

wait_until_running test_web

on_ci_pull_dependent_language_start_point_image
