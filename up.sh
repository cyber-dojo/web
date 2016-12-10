#!/bin/bash
set -e

# You must do a down so the up brings up a new web container
#cyber-dojo down
#cyber-dojo up
#sleep 2

export CYBER_DOJO_ROOT=/usr/src/cyber-dojo
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

start_point_exists()
{
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  set +e
  docker volume ls --quiet | grep -s "${start_of_line}${start_point}${end_of_line}" > /dev/null
  set -e
}

one_time_creation_of_start_point_volumes()
{
  curl https://raw.githubusercontent.com/cyber-dojo/commander/master/cyber-dojo > /tmp/cyber-dojo
  chmod +x /tmp/cyber-dojo
  local GIT_URL=https://github.com/cyber-dojo/start-points-
  if ! start_point_exists ${CYBER_DOJO_START_POINT_LANGUAGES}; then
    /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_LANGUAGES} \
      --git=${GIT_URL}languages.git
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_EXERCISES}; then
    /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_EXERCISES} \
      --git=${GIT_URL}exercises.git
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_CUSTOM}; then
    /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_CUSTOM} \
      --git=${GIT_URL}custom.git
  fi
}

one_time_creation_of_start_point_volumes

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose --file ${my_dir}/docker-compose.yml up -d

