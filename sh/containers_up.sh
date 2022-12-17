#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - -
wait_until_healthy()
{
  printf "Waiting until ${1} is healthy."
  local n=50
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter health=healthy --format '{{.Names}}' | grep -q "^${1}$" ; then
      printf "\n"
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo "ERROR: ${1} not healthy after 5 seconds."
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -
wait_until_running()
{
  printf "Waiting until ${1} is running."
  local n=50
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q "^${1}$" ; then
      printf "\n"
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo "ERROR: ${1} not running after 5 seconds."
  docker logs "${1}"
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - -

containers_up()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose.yml" \
    up \
    -d \
    --force-recreate \
    web

  wait_until_healthy test_web_runner
  wait_until_running test_web_saver
  wait_until_running test_web
}
