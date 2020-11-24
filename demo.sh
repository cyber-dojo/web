#!/bin/bash -Eeu

# Brings up a local server (without using commander).

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${ROOT_DIR}/sh/echo_versioner_env_vars.sh"
source "${ROOT_DIR}/sh/container_info.sh"
source "${ROOT_DIR}/sh/copy_in_saver_test_data.sh"
source "${ROOT_DIR}/sh/ip_address.sh"
export $(echo_versioner_env_vars)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_installed()
{
  if ! installed "${1}" ; then
    stderr 'ERROR: ${1} is not installed!'
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

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
remove 3000 # web
web_build
remove 80 # nginx
up_nginx
#copy_in_saver_test_data # eg 5U2J18 (v1)  5rTJv5 (v0)
if on_Mac; then
  open "$(demo_URL)"
else
  echo "Demo URL is $(demo_URL)"
fi
