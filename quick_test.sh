#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

CYBER_DOJO_HOME=/usr/src/cyber-dojo

docker build \
  --build-arg CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
  --file ${my_dir}/Dockerfile \
  --tag cyberdojo/web \
  ${my_dir}

CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_HOME}/start-points/languages
CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_HOME}/start-points/exercises
CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_HOME}/start-points/custo

docker run \
  --rm \
  -it \
  -v languages:/usr/src/cyber-dojo/start-points/languages:ro \
  -v exercises:/usr/src/cyber-dojo/start-points/exercises:ro \
  -v custom:/usr/src/cyber-dojo/start-points/custom:ro \
  --env CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_LANGUAGES_ROOT} \
  --env CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_EXERCISES_ROOT} \
  --env CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_CUSTOM_ROOT} \
  cyberdojo/web \
  sh -c "cd test/app_models && ./avatar_test.rb ${*}"

#sh -c "cd start-points/languages && ls -al"
