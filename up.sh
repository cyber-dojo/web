#!/bin/bash
set -e

export CYBER_DOJO_ROOT=/usr/src/cyber-dojo
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

one_time_creation_of_start_point_volumes()
{
  curl https://raw.githubusercontent.com/cyber-dojo/commander/master/cyber-dojo > /tmp/cyber-dojo
  chmod +x /tmp/cyber-dojo
  local GIT_URL=https://github.com/cyber-dojo/start-points-
  set +e
  # These all fail (and do nothing) if the start-point already exists
  /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_LANGUAGES} \
      --git=${GIT_URL}languages.git
  /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_EXERCISES} \
      --git=${GIT_URL}exercises.git
  /tmp/cyber-dojo start-point create ${CYBER_DOJO_START_POINT_CUSTOM} \
      --git=${GIT_URL}custom.git
  set -e
  rm /tmp/cyber-dojo
}

#one_time_creation_of_start_point_volumes

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose --file ${my_dir}/docker-compose.yml up -d

