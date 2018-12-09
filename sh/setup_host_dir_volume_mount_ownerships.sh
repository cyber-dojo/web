#!/bin/bash
set -e

chown_dir()
{
  # The dirs have already been created via the
  # docker_containers_up.sh command.
  # See the volume-mounts in docker-compose.yml
  local dir_name=$1
  local gid=$2
  local command="cd ${dir_name} && sudo rm -rf * && sudo chown -R ${gid}:${gid} ."
  if [[ ! -z ${DOCKER_MACHINE_NAME} && -z ${TRAVIS} ]]; then    
    docker-machine ssh default "${command}"
  else
    ${command}
  fi
}

echo "clearing out /tmp/id-map and setting its ownership to porter"
chown_dir '/tmp/id-map' 19664

echo "clearing out /tmp/groups and setting its ownership to saver"
chown_dir '/tmp/groups' 19663

echo "clearing out /tmp/katas and setting its ownership to saver"
chown_dir '/tmp/katas'  19663
