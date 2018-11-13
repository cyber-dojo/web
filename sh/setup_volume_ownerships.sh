#!/bin/bash
set -e

chown_dir()
{
  local dir_name=$1
  local gid=$2
  local command="cd /tmp/${dir_name} && sudo rm -rf * && sudo chown -R ${gid} ."
  if [[ ! -z ${DOCKER_MACHINE_NAME} ]]; then
    command="docker-machine ssh default '${command}'"
  fi
  eval ${command}
}

echo "setting ownership in porter"
chown_dir 'id-map' 19664

echo "setting ownership in saver"
chown_dir 'groups' 19663
chown_dir 'katas'  19663
