#!/usr/bin/env bash
set -Eeu

# Brings up a local server (without using commander).

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"

source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/copy_in_saver_test_data.sh"
source "${BIN_DIR}/create_v2_kata.sh"
source "${BIN_DIR}/lib.sh"
export $(echo_env_vars)

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
      --name test_web_nginx \
      nginx
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed docker
docker ps -aq | xargs docker rm -f
web_build
up_nginx
copy_in_saver_test_data # eg 5U2J18 (v1)  5rTJv5 (v0)
id="$(create_v2_kata)"
echo "v2 Kata ID=${id}"
open "http://localhost:80/kata/edit/${id}"
