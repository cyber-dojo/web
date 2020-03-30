#!/bin/bash -Eeu

# Script to build a web image whose Dockerfile does *not*
# COPY web's source; instead web's source is volume-mounted
# into the container. This allows for a faster feedback loop
# when working on, eg CSS.
# However, it's not finished yet. The server starts
# $ rails server --environment=production
# and in production mode it does not see changed files.
# It needs to be development|test, but either they're
# not configured, or nginx is caching.

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
echo "WARNING: This is not working yet..."
build
run
