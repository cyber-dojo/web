#!/usr/bin/env bash
set -Eeu

# Brings up a local server (without using commander).

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/copy_in_saver_test_data.sh"
source "${SH_DIR}/ip_address.sh"

export $(echo_versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - -
docker_rm()
{
  docker rm --force "${1}" 2> /dev/null || true
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

# - - - - - - - - - - - - - - - - - - - - - - - -
on_Mac()
{
  [ "$(uname)" == "Darwin" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
demo_URL()
{
  echo "http://$(ip_address):80/kata/edit/5U2J18"
}

# - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed docker
exit_non_zero_unless_installed docker-compose
docker_rm test_web
web_build
docker_rm test_web_nginx
up_nginx
copy_in_saver_test_data # eg 5U2J18 (v1)  5rTJv5 (v0)
if on_Mac ; then
  open "$(demo_URL)"
else
  echo "Demo URL is $(demo_URL)"
fi
