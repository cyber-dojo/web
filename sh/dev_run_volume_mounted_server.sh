#!/bin/bash -Eeu

# Brings up a local server (without using commander).
# Does *not* COPY the web source into the web image.
# Instead it volume-mounts web source into the web container.
# Execute sh/run_tests_in_container.sh
# for a very fast feedback loop.

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/sh/versioner_env_vars.sh"
source "${ROOT_DIR}/sh/container_info.sh"
export $(versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
remove()
{
  local -r port="${1}"
  docker rm --force $(container_on_port "${port}") 2> /dev/null || true
}

# - - - - - - - - - - - - - - - - - - - - - - -
web_build()
{
  local commit_sha=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA=${commit_sha} \
    --build-arg BUILD_ENV=no_copy
}

# - - - - - - - - - - - - - - - - - - - - - - -
up_nginx()
{
  remove 80 # web
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-choosers.yml" \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose-nginx.yml" \
    --file "${ROOT_DIR}/docker-compose-saver-dir-volume-mount.yml" \    
    --file "${ROOT_DIR}/docker-compose-web-volume-mount.yml" \
    run \
      --detach \
      --name test_web_nginx \
      --service-ports \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
remove 3000 #web
web_build
up_nginx
