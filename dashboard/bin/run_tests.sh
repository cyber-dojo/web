#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client} [ID...]

    Options:
      client  - run tests inside the client container only
      server  - run tests inside the server container only
      ID...   - run tests matching these identifiers only

    Example:
      ${MY_NAME} server 0D6
      ...
      Finished tests in 0.027497s, 72.7358 tests/s, 72.7358 assertions/s.
      2 tests, 2 assertions, 0 failures, 0 errors, 0 skips
      ...

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server')
      export USER="${CYBER_DOJO_DASHBOARD_SERVER_USER}"
      ;;
    'client')
      export USER="${CYBER_DOJO_DASHBOARD_CLIENT_USER}"
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit_non_zero
      ;;
    *)
      show_help
      stderr "first argument is '${1:-}' - must be 'client' or 'server'"
      exit_non_zero
  esac
}

run_tests()
{
  check_args "$@"

  local -r TYPE="${1}"           # {server|client}
  local -r TEST_LOG=test.log
  local -r CONTAINER_COVERAGE_DIR="/tmp/reports"
  local -r HOST_REPORTS_DIR="${ROOT_DIR}/reports/${TYPE}"

  if [ "${TYPE}" == 'server' ]; then 
    local -r SERVICE=dashboard
  else 
    local -r SERVICE=client
  fi

  # Don't do a build here, because in CI workflow, server image is built with GitHub Action
  docker compose --progress=plain up --no-build --wait --wait-timeout=10 "${SERVICE}"
  # Resolve the container now it is up; Compose namespaces it by project+service.
  export CONTAINER_NAME="$(service_container "${SERVICE}")"
  echo_warnings "${SERVICE}"
  copy_in_saver_test_data

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  # CONTAINER_NAME is running with read-only:true and a non-root user (in docker-compose.yml). I want to
  # keep those settings in the docker-exec call below since that is how I want the microservice to run.
  # The [docker exec run.sh] is creating coverage files which I process on the host after it completes.
  # I've tried using an :rw volume mount (eg /reports) in docker-compose.yml and writing the
  # coverage files to /reports, so they automatically end up on the host. I cannot find a way that works
  # on both my M2 laptop, and in the CI workflow. So I am writing the coverage files to /tmp and
  # tar-piping them out.

  set +e
  docker exec \
    --env COVERAGE_CODE_TAB_NAME=app \
    --env COVERAGE_TEST_TAB_NAME=test \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/dashboard/test/run.sh ${CONTAINER_COVERAGE_DIR} ${TEST_LOG} ${TYPE} ${*:2} ${tid:-}"
  local -r STATUS=$?
  set -e

  rm -rf "${HOST_REPORTS_DIR}" &> /dev/null || true
  mkdir -p "${HOST_REPORTS_DIR}" &> /dev/null || true

  docker exec --user "${USER}" "${CONTAINER_NAME}" tar Ccf "${CONTAINER_COVERAGE_DIR}" - . \
    | tar Cxf "${HOST_REPORTS_DIR}" -

  # Check we generated the expected files.
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/${TEST_LOG}"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/index.html"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/test_metrics.json"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"

  echo "${SERVICE} test branch-coverage report is at:"
  echo "${HOST_REPORTS_DIR}/index.html"
  echo
  echo "${TYPE} test status == ${STATUS}"
  echo

  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi

  return ${STATUS}
}

run_tests "$@"