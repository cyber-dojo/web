#!/bin/bash
set -e

chown_saver_dir()
{
  # The dirs have already been created via the
  # docker_containers_up.sh command.
  # See the volume-mounts in docker-compose.yml
  local dir_name=$1
  local gid=19663
  local command="cd ${dir_name} && rm -rf * && chown -R ${gid}:${gid} ."
  docker exec --user root test-web-saver sh -c "${command}"
  #if [[ ! -z ${DOCKER_MACHINE_NAME} && -z ${TRAVIS} ]]; then
  #  echo "...running: docker-machine ssh default '${command}'"
  #  docker-machine ssh default "${command}"
  #else
  #  echo "...running: ${command}"
  #  ${command}
  #fi
}

echo "clearing out /groups and setting its ownership to saver"
chown_saver_dir '/groups'

echo "clearing out /tmp/katas and setting its ownership to saver"
chown_saver_dir '/katas'
