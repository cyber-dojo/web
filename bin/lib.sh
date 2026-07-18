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
  if [ "${1}" == docker ]; then
    echo_ci_resolved_versions
  fi
}

echo_ci_resolved_versions()
{
  # On a CI run, print the versioner image's own repo digest and the service
  # image tags/digests it resolved into /tmp/cyber-dojo.env-vars. This makes
  # the exact versions under test visible in the CI log, so a versioner or
  # service version mismatch is diagnosable directly from the log rather than
  # by reconstructing registry push timelines. Does nothing off CI.
  if [ -z "${GITHUB_ACTIONS:-}" ]; then
    return
  fi
  local -r versioner_digest="$(docker inspect \
    --format '{{index .RepoDigests 0}}' \
    cyberdojo/versioner:latest 2>/dev/null || echo unknown)"
  echo "CI resolved versions (from cyberdojo/versioner:latest):"
  echo "  versioner = ${versioner_digest}"
  grep --extended-regexp '_(IMAGE|TAG|DIGEST)=' /tmp/cyber-dojo.env-vars || true
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
