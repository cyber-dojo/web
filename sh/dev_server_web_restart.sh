#!/bin/bash -Eeu

# Rebuilds and restarts the web service (without using commander).
# Use after bringing up a server with /sh/dev_server_up.sh
# Gives a reasonably fast ux feedback loop.
#   o) edit the web source
#   o) rerun this script
#   o) refresh the browser
#
# TODO: saver has no persistence (uses tmpfs)

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${ROOT_DIR}/sh/versioner_env_vars.sh
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
web_build()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg BUILD_ENV=copy
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_remove()
{
  docker rm --force $(container_on_port 3000)
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_run()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-choosers.yml" \
    --file "${ROOT_DIR}/docker-compose-nginx.yml" \
    run \
      --detach \
      --service-ports \
      web
}

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

# - - - - - - - - - - - - - - - - - - - - - - -
web_build
web_remove
web_run
