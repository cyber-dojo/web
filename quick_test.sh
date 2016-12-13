#!/bin/bash
set -e

# NB: Missing links to external services - non unit-tests will fail

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

CYBER_DOJO_HOME=/app

docker build \
  --build-arg CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
  --file ${my_dir}/Dockerfile \
  --tag cyberdojo/web \
  ${my_dir}

CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_HOME}/start-points/languages
CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_HOME}/start-points/exercises
CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_HOME}/start-points/custom

docker run \
  --rm \
  --tty \
  --volume languages:${CYBER_DOJO_HOME}/start-points/languages:ro \
  --volume exercises:${CYBER_DOJO_HOME}/start-points/exercises:ro \
  --volume custom:${CYBER_DOJO_HOME}/start-points/custom:ro \
  --env CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_LANGUAGES_ROOT} \
  --env CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_EXERCISES_ROOT} \
  --env CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_CUSTOM_ROOT} \
  cyberdojo/web \
  sh -c "cd test/app_lib && ./run.sh ${*}"
