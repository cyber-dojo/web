#!/usr/bin/env bash
set -Eeu

# Brings up a local server (without using commander).

repo_root() { git rev-parse --show-toplevel; }
readonly SH_DIR="$(repo_root)/sh"

source "${SH_DIR}/echo_env_vars.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/lib.sh"
export $(echo_env_vars)

docker_rm()
{
  docker rm --force "${1}" 2> /dev/null || true
}

web_build()
{
  docker compose \
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
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    run \
      --detach \
      --name test_web_nginx \
      --service-ports \
      nginx
}

demo_URL()
{
  echo "http://localhost:80/kata/edit/5U2J18"
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed docker
docker_rm test_web
web_build
docker_rm test_web_nginx
up_nginx
copy_in_saver_test_data # eg 5U2J18 (v1)  5rTJv5 (v0)
open "$(demo_URL)"
