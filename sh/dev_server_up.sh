#!/bin/bash -Eeu

# Brings up a local server without using commander.
# Intended for dev use. Once the server is up
# you use the dev_web_restart.sh script to rebuild
# and restart the web service.

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${ROOT_DIR}/sh/versioner_env_vars.sh
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
nginx_up()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-choosers.yml" \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose-nginx.yml" \
    run \
      --detach \
      --service-ports \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
nginx_up
