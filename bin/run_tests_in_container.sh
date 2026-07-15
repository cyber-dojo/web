#!/usr/bin/env bash
set -Eeu

#- - - - - - - - - - - - - - - - - - - -
# Copy saver-test-data into saver container
# Done here to ensure it always happens before tests are run.

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

run_tests_in_container()
{
  # Resolved here (not at source-time) because the containers are not up
  # until run_tests.sh calls containers_up, which happens after this file
  # is sourced.
  local -r SAVER_CID="$(service_container saver)"

  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}

  #- - - - - - - - - - - - - - - - - - - -
  # Now docker exec in and run the tests
  local -r WEB_CID="$(service_container web)"
  local -r SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
  local -r DST=$(repo_root)/coverage

  # Drop set -e because we want to get coverage stats out
  set +e
  docker exec --user nobody "${WEB_CID}" sh -c "cd /web/source/test && ./run.sh ${*:-}"
  local -r UNIT_STATUS=$?

  # Browser (Capybara + Selenium) tests run as a separate script: they exercise
  # the served app end-to-end, so they are kept out of run.sh's per-module
  # coverage loop. Only on a full run (no single module requested).
  local BROWSER_STATUS=0
  if [ $# -eq 0 ]; then
    docker exec --user nobody "${WEB_CID}" sh -c "cd /web/source/test && ./run_browser.sh"
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
