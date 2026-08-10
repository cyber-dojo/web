#!/usr/bin/env bash
set -Eeu

readonly SRC_PATH=$(repo_root)/test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

pull_runner_test_image()
{
  # The runner's config.ru calls [docker image ls] at startup and pre-loads
  # every locally-present image into its in-memory @pulled set before forking
  # Puma workers. This pull must therefore happen before containers_up so that
  # the image is present when the runner starts and all workers inherit it.
  local -r manifest="$(repo_root)/test/data/cyber-dojo/katas/5U/2J/18/manifest.json"
  local -r image=$(jq --raw-output '.image_name' "${manifest}")
  docker pull --quiet "${image}"
}

copy_saver_test_data()
{
  # Copy saver-test-data into the saver container so the tests (and the app the
  # browser tests drive) can read the test katas. Done before any tests run.
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  local -r SAVER_CID="$(service_container saver)"
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}
}

run_client_tests_in_container()
{
  # Browser (Capybara + Selenium) tests exercise the served app end-to-end (via
  # Firefox in the selenium container), so they run as a separate script from
  # run_server.sh and are kept out of its coverage run. Returns the test run's
  # exit status.
  local -r WEB_CID="$(service_container web)"
  docker exec --user nobody "${WEB_CID}" \
    sh -c "cd /web/test && ./run_client.sh ${*:-}"
}

run_server_tests_in_container()
{
  # The container ids are resolved here (not at source-time) because the
  # containers are not up until run_server_tests.sh calls containers_up, which
  # happens after this file is sourced.
  copy_saver_test_data

  #- - - - - - - - - - - - - - - - - - - -
  # Now docker exec in and run the tests
  local -r WEB_CID="$(service_container web)"
  local -r SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
  # reports/ is where every sibling repo leaves its generated reports, and
  # where bin/check_coverage_metrics.sh and the CI attestations look for them.
  local -r DST=$(repo_root)/reports

  # Drop set -e because we want to get coverage stats out
  set +e
  docker exec --user nobody "${WEB_CID}" sh -c "cd /web/test && ./run_server.sh ${*:-}"
  local -r UNIT_STATUS=$?
  set -e

  mkdir -p "${DST}"
  docker cp "${SRC}/." "${DST}"
  echo
  echo "${DST}/index.html"

  return ${UNIT_STATUS}
}
