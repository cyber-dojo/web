#!/usr/bin/env bash
set -Eeu

exit_non_zero_unless_installed()
{
  printf "Checking ${1} is installed..."
  if ! installed "${1}" ; then
    stderr "ERROR: ${1} is not installed!"
    exit_non_zero
  fi
  if [ "${1}" == docker ]; then
    set +e
    docker run --rm cyberdojo/versioner:latest > /tmp/cyber-dojo.env-vars 2>&1
    local -r STATUS=$?
    set -e
    if [ "${STATUS}" != "0" ]; then
      stderr ERROR: docker not working
      cat /tmp/cyber-dojo.env-vars
      exit_non_zero
    fi
  fi
  echo It is
}

installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

service_container()
{
  # Echo the container id of the given docker-compose service within
  # this demo's project. The project is COMPOSE_PROJECT_NAME (set by
  # bin/demo.sh), defaulting to web so the saver/test helpers work
  # against a plain demo when the var is not exported in the shell.
  local -r service="${1}"
  docker ps \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME:-web}" \
    --filter "label=com.docker.compose.service=${service}" \
    --format '{{.ID}}'
}

stderr()
{
  >&2 echo "${1}"
}

exit_non_zero()
{
  kill -INT $$
}
