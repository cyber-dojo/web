
# Each app in this repo runs its containers as its own compose project, so one
# app's test run or demo never stops or finds another app's containers.
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-creator}"

# Every bare 'docker compose' in these scripts reads the repo's shared files,
# so each one sees creator, nginx, selenium and the services they depend on.
readonly COMPOSE_DIR="$(git rev-parse --show-toplevel)"
export COMPOSE_FILE="${COMPOSE_DIR}/docker-compose-depends.yml:${COMPOSE_DIR}/docker-compose-nginx.yml:${COMPOSE_DIR}/docker-compose-selenium.yml:${COMPOSE_DIR}/docker-compose.yml"

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    printf "Checking %s is installed..." "${dependent}"
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed"
      exit_non_zero
    else
      echo It is
    fi
  done
}

exit_non_zero_unless_docker_running()
{
  # 'docker' being installed (on the PATH) does not mean its daemon is up.
  # Every bin/ script here shells out to docker/docker-compose, so a stopped
  # daemon otherwise surfaces far downstream as a cryptic failure (eg the demo
  # curling an empty CYBER_DOJO_CREATOR_PORT because the versioner container
  # never ran). 'docker info' talks to the daemon and fails fast if it is down.
  printf "Checking the docker daemon is running..."
  if ! docker info > /dev/null 2>&1 ; then
    stderr "the docker daemon is not running"
    exit_non_zero
  else
    echo It is
  fi
}

installed()
{
  local -r dependent="${1}"
  if hash "${dependent}" 2> /dev/null; then
    true
  else
    false
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

exit_non_zero()
{
  exit 42
}

repo_root()
{
  git rev-parse --show-toplevel
}

service_container()
{
  # Echo the container id of the given docker-compose service within this
  # app's compose project, COMPOSE_PROJECT_NAME (exported at the top of this
  # file).
  local -r service="${1}"
  docker ps \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
    --filter "label=com.docker.compose.service=${service}" \
    --format '{{.ID}}'
}

service_container_any_state()
{
  # Like service_container, but also matches stopped/exited containers (via
  # --all). service_container uses a running-only 'docker ps', which is right
  # for the health check and for docker-exec-ing into a live container, but
  # useless for diagnosing a container that crashed on boot: by the time we
  # want its logs it has already exited, 'docker ps' returns nothing, and
  # 'docker logs ""' dies with "invalid container name or ID: value is empty".
  # This finds the exited container so echo_docker_log can still read its logs.
  local -r service="${1}"
  docker ps --all \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
    --filter "label=com.docker.compose.service=${service}" \
    --format '{{.ID}}' \
    | head -n 1
}

git_commit_sha()
{
  cd "$(repo_root)" && git rev-parse HEAD
}

get_image_tag()
{
  local -r sha="$(git_commit_sha)"
  echo "${sha:0:7}"
}

on_ci()
{
  [ -n "${CI:-}" ]
}

write_test_evidence_json()
{
  {
    echo '{ "server": '
    cat "$(repo_root)/app-creator/test/server/reports/coverage_metrics.json"
    if [ "${1:-}" != 'server' ]; then
      echo ', "client": '
      cat "$(repo_root)/app-creator/test/client/reports/coverage_metrics.json"
    fi
    echo '}'
  } | jq . > "$(test_evidence_json_path)"
}

test_evidence_json_path()
{
  echo "$(repo_root)/app-creator/test/evidence.json"
}
