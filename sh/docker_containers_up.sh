#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
. ${ROOT_DIR}/env_vars.sh

one_time_creation_of_start_point_volumes()
{
  local NAME=/tmp/cyber-dojo-one-time
  curl https://raw.githubusercontent.com/cyber-dojo/commander/master/cyber-dojo > ${NAME}
  chmod +x ${NAME}
  local GIT_URL=https://github.com/cyber-dojo/start-points-
  set +e
  # These all fail (and do nothing) if the start-point already exists
  ${NAME} start-point create ${CYBER_DOJO_START_POINT_LANGUAGES} \
      --list=https://raw.githubusercontent.com/cyber-dojo/start-points-languages/master/languages_list_travis 2> /dev/null
  ${NAME} start-point create ${CYBER_DOJO_START_POINT_EXERCISES} \
      --git=${GIT_URL}exercises.git 2> /dev/null
  ${NAME} start-point create ${CYBER_DOJO_START_POINT_CUSTOM} \
      --git=${GIT_URL}custom.git 2> /dev/null
  set -e
  rm ${NAME}
}

one_time_creation_of_start_point_volumes

docker-compose --file ${ROOT_DIR}/docker-compose.yml up -d
sleep 2