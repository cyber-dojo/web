#!/bin/bash -Eeux

# Rebuilds and restarts the web service (without using commander).
# Use after bringing up a server with /sh/dev_server_up.sh
# Gives a reasonably fast ux feedback loop.
#   o) edit the web source
#   o) rerun this script
#   o) refresh the browser
#
# TODO: saver has no persistence (uses tmpfs)

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/sh/versioner_env_vars.sh"
source "${ROOT_DIR}/sh/container_info.sh"
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
  docker rm --force $(container_on_port 3000) || true
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_run()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    run \
      --detach \
      --name cyber_dojo_web \
      --service-ports \
      web
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_build
web_remove
web_run
