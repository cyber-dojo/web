#!/bin/bash -Eeu

# Script to build a web image whose Dockerfile does *not*
# COPY web's source; instead web's source is volume-mounted
# into the container. This allows for a faster feedback loop
# when working on, eg CSS.
# However, it's not working yet... The server starts
# $ rails server --environment=production
# and in production mode it does not see changed files.
# It needs to be --environment=development, but that causes
# 502 Bad Gateway. nginx/1.17.9
# and [docker logs nginx] reveals
#   2020/03/30 21:35:31 [error]
#   7#7: *1 connect() failed (111: Connection refused) while connecting to upstream,
#   client: 192.168.99.1,
#   server: localhost,
#   request: "GET /dojo/index/ HTTP/1.1",
#   upstream: "http://172.29.0.13:3000/dojo/index/",
#   host: "192.168.99.100"

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
      --service-ports \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
echo "WARNING: This is not working yet...nginx refusing upstream 3000:connection ?"
build
run
