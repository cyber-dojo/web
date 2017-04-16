#!/bin/bash

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

CYBER_DOJO_HOME=/app
CYBER_DOJO_START_POINT_ROOT=${CYBER_DOJO_HOME}/start-points
CYBER_DOJO_LANGUAGES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/languages
CYBER_DOJO_EXERCISES_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/exercises
CYBER_DOJO_CUSTOM_ROOT=${CYBER_DOJO_START_POINTS_ROOT}/custom

cid=$(docker run \
    -d \
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
    --env CYBER_DOJO_UNIT_TEST=true \
    cyberdojo/web \
    sh)

modules=( app_helpers app_lib lib ) # app_models app_controllers )
for module in ${modules[*]}
do
  docker exec --env CYBER_DOJO_TEST_MODULES="${module}" \
    ${cid} sh -c "cd test && ./run.sh ${*}"
done

docker rm -f ${cid} > /dev/null
