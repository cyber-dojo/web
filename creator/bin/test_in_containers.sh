
# - - - - - - - - - - - - - - - - - - - - - - - - - -
test_in_containers()
{
  set +e
  status=0

  if [ "${1:-}" = 'server' ]; then
    shift
    run_server_tests "${@:-}" || status=$?
  elif [ "${1:-}" = 'client' ]; then
    shift
    run_client_tests "${@:-}" || status=$?
  else
    run_server_tests "${@:-}" || status=$?
    run_client_tests "${@:-}" || status=$?
  fi

  set -e
  return $status
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_client_tests()
{
  # The browser tests run in the creator container, like the server tests, and
  # reach the app through nginx and selenium.
  run_tests \
    "${CYBER_DOJO_CREATOR_SERVER_USER}" \
    creator \
    client "${@:-}";
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests()
{
  run_tests \
    "${CYBER_DOJO_CREATOR_SERVER_USER}" \
    creator \
    server "${@:-}";
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r USER="${1}"    # eg nobody
  local -r SERVICE="${2}" # compose service, eg creator
  local -r TYPE="${3}"    # eg server

  # Containers are no longer given fixed names (so concurrent demos/tests in
  # sibling repos do not collide), so resolve the service's container id by
  # its compose project+service label - see service_container in lib.sh.
  local -r CONTAINER_NAME="$(service_container "${SERVICE}")"

  echo '=================================='
  echo "Running ${TYPE} tests"
  echo '=================================='

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run tests (with branch coverage) inside the container.

  local -r TEST_LOG=test.log
  local -r CONTAINER_REPORTS_DIR=/tmp/reports

  local -r HOST_TEST_DIR="$(repo_root)/creator/test/${TYPE}"   # where to extract to. untar will create reports/ dir
  local -r HOST_REPORTS_DIR="${HOST_TEST_DIR}/reports" # where files will be

  rm -rf "${HOST_REPORTS_DIR}" 2> /dev/null || true

  set +e
  docker exec \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "/app/test/run.sh ${CONTAINER_REPORTS_DIR} ${TEST_LOG} ${TYPE} ${*:4}"
  # For a gated suite the metrics checker below reports failures from the log.
  # An ungated suite has nothing else to speak for it, so keep this status.
  local -r RUN_STATUS=$?
  set -e

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Extract test-run results and coverage data from the container.
  # You can't [docker cp] from a tmpfs, so tar-piping coverage out

  rm "${HOST_REPORTS_DIR}/${TEST_LOG}"             2> /dev/null || true
  rm "${HOST_REPORTS_DIR}/index.html"              2> /dev/null || true
  rm "${HOST_REPORTS_DIR}/coverage_metrics.json"   2> /dev/null || true
  rm "${HOST_REPORTS_DIR}/test_metrics.json"       2> /dev/null || true
  rm "${HOST_REPORTS_DIR}/log_metrics.json"        2> /dev/null || true

  docker exec \
    "${CONTAINER_NAME}" \
    tar Ccf \
      "$(dirname "${CONTAINER_REPORTS_DIR}")" \
      - "$(basename "${CONTAINER_REPORTS_DIR}")" \
        | tar Cxf "${HOST_TEST_DIR}/" -

  # Check we generated expected files.
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/${TEST_LOG}"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/index.html"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/test_metrics.json"
  exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/log_metrics.json"

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Process test-run results and coverage data.
  #
  # A suite is gated only if it pins metrics. The browser tests do not: they
  # drive the served app through nginx and Firefox, so in-process line and
  # branch coverage says nothing about what they exercised, and creator's
  # zero-missed pins could never be met by them.

  if [ ! -d "${HOST_TEST_DIR}/config" ]; then
    echo "${TYPE} test branch-coverage report is at"
    echo "${HOST_REPORTS_DIR}/index.html"
    echo "${TYPE} tests pin no metrics, so only the run's own status counts."
    echo "${TYPE} test status == ${RUN_STATUS}"
    echo
    return "${RUN_STATUS}"
  fi

  local -r CONTAINER_TMP_DIR=/tmp # fs is read-only with tmpfs at /tmp

  # One data file, one limits file, one run each. The evaluator is generic: it
  # walks a dotted path into the json and applies the operator the limits file
  # names, so a limit changes in a file that holds nothing but limits. Mirrors
  # ../saver, which is where this shape comes from.
  set +e
  local STATUS=0
  local pair
  for pair in \
    "test_metrics.json test_metrics_limits" \
    "coverage_metrics.json coverage_metrics_limits" \
    "log_metrics.json log_metrics_limits"
  do
    set -- ${pair}
    local data_file="${1}"
    local limits_file="${2}"
    docker run \
      --rm \
      --platform linux/amd64 \
      --volume ${HOST_REPORTS_DIR}/${data_file}:${CONTAINER_TMP_DIR}/${data_file}:ro \
      --volume ${HOST_TEST_DIR}/config/check_metrics.rb:${CONTAINER_TMP_DIR}/check_metrics.rb:ro \
      --volume ${HOST_TEST_DIR}/config/${limits_file}.rb:${CONTAINER_TMP_DIR}/${limits_file}.rb:ro \
      "${CYBER_DOJO_CREATOR_IMAGE}:${CYBER_DOJO_CREATOR_TAG}" \
        sh -c "ruby ${CONTAINER_TMP_DIR}/check_metrics.rb ${CONTAINER_TMP_DIR}/${data_file} ${limits_file}" \
      | tee -a "${HOST_REPORTS_DIR}/${TEST_LOG}"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then STATUS=1; fi
  done
  set -e

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Tell caller where the results are...

  echo "${TYPE}" test branch-coverage report is at
  echo "${HOST_REPORTS_DIR}/index.html"
  echo "${TYPE} test status == ${STATUS}"
  echo
  if [ "${STATUS}" != 0 ]; then
    echo Docker logs "${CONTAINER_NAME}"
    echo
    docker logs "${CONTAINER_NAME}" 2>&1
  fi
  return "${STATUS}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit_non_zero
  fi
}
