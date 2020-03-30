#!/bin/bash -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source ${ROOT_DIR}/sh/versioner_env_vars.sh
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
build()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg BUILD_ENV=no_copy
}

# - - - - - - - - - - - - - - - - - - - - - - -
run()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-run.yml" \
    run \
      --detach \
      --publish 80:80 \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
build
run
