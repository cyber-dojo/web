#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - -
name_port_ls()
{
  docker container ls --format "{{.Names}} {{.Ports}}" --all
}

# - - - - - - - - - - - - - - - - - - -
container_on_port()
{
  local -r port="${1}"
  name_port_ls | grep "${port}" | cut -f 1 -d " "
}

# - - - - - - - - - - - - - - - - - - -
service_container()
{
  local -r service_name="${1}"
  name_port_ls | grep "${service_name}" | cut -f 1 -d " "
}

# - - - - - - - - - - - - - - - - - - -
service_port()
{
  local -r service_name="${1}"
  name_port_ls | grep "${service_name}" | cut -f 2 -d '>' | cut -f 1 -d '/'
}

# - - - - - - - - - - - - - - - - - - -
: <<'COMMENT'

$ name_port_ls
cyber-dojo_creator_1 0.0.0.0:4523->4523/tcp
cyber-dojo_saver_1 0.0.0.0:4537->4537/tcp
cyber-dojo_languages-start-points_1 0.0.0.0:4524->4524/tcp
cyber-dojo_custom-start-points_1 0.0.0.0:4526->4526/tcp
cyber-dojo_exercises-start-points_1 0.0.0.0:4525->4525/tcp

1.To get the name of the container running a port 4523
  $ name_port_ls | grep 4523 | cut -f 1 -d " "

2.To get port for container called xxx
  $ name_port_ls | grep xxx | cut -f 2 -d '>' | cut -f 1 -d '/'

3.To get container for a service called xxx
  $ name_port_ls | grep xxx | cut -f 1 -d " "

4.To get the port for a service called xxx
  $ name_port_ls | grep xxx | cut -f 2 -d '>' | cut -f 1 -d '/'

COMMENT
