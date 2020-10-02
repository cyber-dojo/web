#!/bin/bash -Eeu

# Brings up a local server (without using commander).
# COPYies the web source into the web image.
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
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA="$(git_commit_sha)"
}

# - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

# - - - - - - - - - - - - - - - - - - - - - - -
up_nginx()
{
  remove 80 # web
  docker-compose \
    --file "${ROOT_DIR}/docker-compose-depends.yml" \
    --file "${ROOT_DIR}/docker-compose-nginx.yml" \
    --file "${ROOT_DIR}/docker-compose.yml" \
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
