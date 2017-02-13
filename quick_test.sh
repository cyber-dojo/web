#!/bin/bash
set -e

# NB: This does not have links to external services
#     non unit-tests will fail

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

CYBER_DOJO_HOME=/app
CYBER_DOJO_START_POINT_ROOT=${CYBER_DOJO_HOME}/start-points
CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/languages
CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/exercises
CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/custom

docker run \
  --rm \
  --tty \
  --user cyber-dojo \
  --volume ${my_dir}/app:${CYBER_DOJO_HOME}/app:ro \
  --volume ${my_dir}/lib:${CYBER_DOJO_HOME}/lib:ro \
  --volume ${my_dir}/test:${CYBER_DOJO_HOME}/test:ro \
  --volume languages:${CYBER_DOJO_START_POINTS_ROOT}/languages:ro \
  --volume exercises:${CYBER_DOJO_START_POINTS_ROOT}/exercises:ro \
  --volume custom:${CYBER_DOJO_START_POINTS_ROOT}/custom:ro \
  --env CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
  --env CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_LANGUAGES_ROOT} \
  --env CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_EXERCISES_ROOT} \
  --env CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_CUSTOM_ROOT} \
  --env CYBER_DOJO_TEST_MODULES="app_lib" \
  cyberdojo/web \
  sh -c "cd test && ./run.sh ${*}"
