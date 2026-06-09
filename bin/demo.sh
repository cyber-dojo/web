#!/usr/bin/env bash
set -Eeu

# Brings up a local server (without using commander).

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"

source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/copy_in_saver_test_data.sh"
source "${BIN_DIR}/create_v2_kata.sh"
source "${BIN_DIR}/lib.sh"
# Suppress "requested image's platform does not match host platform" warnings on Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export $(echo_env_vars)

# Each demo runs as its own docker-compose project so several demos (in
# this repo and in sibling repos) can run at once without their networks,
# container names or host ports colliding. nginx is the only service
# published to the host; the backend services talk over the project's
# private network. Override these two vars to run a second web demo
# alongside the first, eg:
#   COMPOSE_PROJECT_NAME=web2 CYBER_DOJO_NGINX_HOST_PORT=81 bin/demo.sh
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-web}"
export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-80}"

web_build()
{
  docker --log-level=ERROR compose \
    --file "$(repo_root)/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA="$(git_commit_sha)"
}

git_commit_sha()
{
  git rev-parse HEAD
}

up_nginx()
{
  docker --log-level=ERROR compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    run \
      --detach \
      --service-ports \
      nginx
}

demo_down()
{
  # Tear down only this demo's project (COMPOSE_PROJECT_NAME), leaving
  # any other repo's running demo untouched.
  docker --log-level=ERROR compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    down --remove-orphans 2>/dev/null || true
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed docker
demo_down
web_build
up_nginx
readonly COUNT="${1:-1}"
readonly KATA_VERSION="${2:-2}"
copy_in_saver_test_data # eg 5U2J18 (v1)  5rTJv5 (v0)
if [ "${KATA_VERSION}" = "0" ]; then
  echo "v0 Kata ID=5rTJv5"
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/kata/edit/5rTJv5"
elif [ "${KATA_VERSION}" = "1" ]; then
  echo "v1 Kata ID=RNCzUr"
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/kata/edit/RNCzUr"
else
  id="$(create_v2_kata "${COUNT}")"
  echo "v2 Kata ID=${id}"
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/kata/edit/${id}"
fi
