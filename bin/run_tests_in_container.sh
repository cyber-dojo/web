#!/usr/bin/env bash
set -Eeu

#- - - - - - - - - - - - - - - - - - - -
# Copy saver-test-data into saver container
# Done here to ensure it always happens before tests are run.

readonly CONTAINER=test_web_saver
readonly SRC_PATH=$(repo_root)/source/test/data/cyber-dojo
readonly DEST_PATH=/cyber-dojo

pull_runner_test_image()
{
  # The runner service test calls run_cyber_dojo_sh, which requires the kata
  # image to be present. The runner's pull_image endpoint is async, so without
  # this pre-pull the image may still be downloading when the test runs and
  # cause a timeout. Pulling here works because the runner container shares the
  # host Docker socket, so an image pulled on the host is immediately available
  # to the runner.
  local -r manifest="$(repo_root)/source/test/data/cyber-dojo/katas/5U/2J/18/manifest.json"
  local -r image=$(jq --raw-output '.image_name' "${manifest}")
  docker pull --quiet "${image}"
}

run_tests_in_container()
{
  pull_runner_test_image

  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${CONTAINER} tar x -C ${DEST_PATH}

  #- - - - - - - - - - - - - - - - - - - -
  # Now docker exec in and run the tests
  local -r WEB_CID=$(docker ps --filter status=running --format '{{.Names}}' | grep "^test_web$")
  local -r SRC=${WEB_CID}:/tmp/cyber-dojo/coverage
  local -r DST=$(repo_root)/coverage

  # Drop set -e because we want to get coverage stats out
  set +e
  docker exec --user nobody "${WEB_CID}" sh -c "cd /web/source/test && ./run.sh ${*:-}"
  readonly STATUS=$?
  set -e

  mkdir -p "${DST}"
  docker cp "${SRC}/." "${DST}"
  echo
  echo "${DST}/lib/index.html"
  echo "${DST}/app_models/index.html"
  echo "${DST}/app_services/index.html"
  echo "${DST}/app_controllers/index.html"

  return ${STATUS}
}
