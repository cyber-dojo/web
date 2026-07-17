#!/usr/bin/env bash
set -Eeu

readonly SRC_PATH=$(repo_root)/source/test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

pull_runner_test_image()
{
  # The runner's config.ru calls [docker image ls] at startup and pre-loads
  # every locally-present image into its in-memory @pulled set before forking
  # Puma workers. This pull must therefore happen before containers_up so that
  # the image is present when the runner starts and all workers inherit it.
  local -r manifest="$(repo_root)/source/test/data/cyber-dojo/katas/5U/2J/18/manifest.json"
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

run_browser_tests_in_container()
{
  # Browser (Capybara + Selenium) tests exercise the served app end-to-end (via
  # Firefox in the selenium container), so they run as a separate script from
  # run.sh and are kept out of run.sh's per-module coverage loop. Returns the
  # test run's exit status.
  local -r WEB_CID="$(service_container web)"
  docker exec --user nobody "${WEB_CID}" sh -c "cd /web/source/test && ./run_browser.sh"
}

run_tests_in_container()
{
  # The container ids are resolved here (not at source-time) because the
  # containers are not up until run_tests.sh calls containers_up, which happens
  # after this file is sourced.
  copy_saver_test_data

  #- - - - - - - - - - - - - - - - - - - -
  # Now docker exec in and run the tests
  local -r WEB_CID="$(service_container web)"
  local -r SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
  local -r DST=$(repo_root)/coverage

  # Drop set -e because we want to get coverage stats out
  set +e
  docker exec --user nobody "${WEB_CID}" sh -c "cd /web/source/test && ./run.sh ${*:-}"
  local -r UNIT_STATUS=$?

  # The browser tests run only on a full run (no single module requested).
  local BROWSER_STATUS=0
  if [ $# -eq 0 ]; then
    run_browser_tests_in_container
    BROWSER_STATUS=$?
  fi
  set -e

  mkdir -p "${DST}"
  docker cp "${SRC}/." "${DST}"
  echo
  echo "${DST}/lib/index.html"
  echo "${DST}/app_models/index.html"
  echo "${DST}/app_services/index.html"
  echo "${DST}/app_controllers/index.html"

  if [ ${UNIT_STATUS} -ne 0 ]; then
    return ${UNIT_STATUS}
  fi
  return ${BROWSER_STATUS}
}
