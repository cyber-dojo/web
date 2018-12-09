#!/bin/bash
set -e

chown_saver_dir()
{
  # The dirs have already been created via the
  # docker_containers_up.sh command.
  # See saver's volume-mounts in docker-compose.yml
  local dir_name=$1
  local gid=19663
  local command="cd ${dir_name} && rm -rf * && chown -R ${gid}:${gid} ."
  docker exec --user root test-web-saver sh -c "${command}"
}

echo "clearing out /groups and setting its ownership to saver"
chown_saver_dir '/groups'

echo "clearing out /tmp/katas and setting its ownership to saver"
chown_saver_dir '/katas'
