#!/bin/bash

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

CYBER_DOJO_HOME=/app
CYBER_DOJO_START_POINTS_ROOT=${CYBER_DOJO_HOME}/start-points
CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/languages
CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/exercises
CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/custom

cid=$(docker run \
    --detach \
    --tty \
    --user cyber-dojo \
    --volume ${my_dir}/app:${CYBER_DOJO_HOME}/app:ro \
    --volume ${my_dir}/lib:${CYBER_DOJO_HOME}/lib:ro \
    --volume ${my_dir}/test:${CYBER_DOJO_HOME}/test:ro \
    --volume ${my_dir}/../start-points-languages:${CYBER_DOJO_LANGUAGES_ROOT}:ro \
    --volume ${my_dir}/../start-points-exercises:${CYBER_DOJO_EXERCISES_ROOT}:ro \
    --volume ${my_dir}/../start-points-custom:${CYBER_DOJO_CUSTOM_ROOT}:ro \
    --env CYBER_DOJO_HOME=${CYBER_DOJO_HOME} \
    --env CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_LANGUAGES_ROOT} \
    --env CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_EXERCISES_ROOT} \
    --env CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_CUSTOM_ROOT} \
    --env CYBER_DOJO_UNIT_TEST=true \
    cyberdojo/web \
    sh)

modules=( app_helpers app_lib lib )
#  app_models - gives currently unfathomed flickering reds :(
# app_controllers - todo
for module in ${modules[*]}
do
  docker exec --env CYBER_DOJO_TEST_MODULES="${module}" \
    ${cid} sh -c "cd test && ./run.sh ${*}"
done

docker rm -f ${cid} > /dev/null
