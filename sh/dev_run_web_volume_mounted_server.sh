#!/bin/bash -Eeu

# Brings up a local server (without using commander).
# Does *not* copy the web source into the web image.
# Instead it volume-mounts web source into the web container.
# Execute sh/run_tests_in_container.sh
# for a very fast feedback loop.

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${ROOT_DIR}/sh/versioner_env_vars.sh
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
web_build()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg BUILD_ENV=no_copy
}

# - - - - - - - - - - - - - - - - - - - - - - -
nginx_up()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-choosers.yml" \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose-nginx.yml" \
    --file "${ROOT_DIR}/docker-compose-web-volume-mount.yml" \
    run \
      --detach \
      --service-ports \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_build
nginx_up
