#!/bin/bash
set -e

export CYBER_DOJO_ROOT=/usr/src/cyber-dojo
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

one_time_creation_of_katas_data_volume()
{
  # The katas data-volume is not created as a named volume
  # because it predates that docker feature.
  set +e
  local KDC=$(docker ps --all | grep -s ${CYBER_DOJO_KATAS_DATA_CONTAINER})
  set -e
  if [ "${KDC}" == "" ]; then
    echo "Making katas data-container"
    local CONTEXT_DIR=/tmp/build-katas-data-container
    mkdir -p ${CONTEXT_DIR}
    echo '*' > ${CONTEXT_DIR}/.dockerignore
    echo 'FROM alpine:3.4' > ${CONTEXT_DIR}/Dockerfile
    echo 'RUN adduser -D -H -u 19661 cyber-dojo' >> ${CONTEXT_DIR}/Dockerfile
    echo 'ARG CYBER_DOJO_KATAS_ROOT' >> ${CONTEXT_DIR}/Dockerfile
    echo 'USER root' >> ${CONTEXT_DIR}/Dockerfile
    echo 'RUN  mkdir -p ${CYBER_DOJO_KATAS_ROOT}' >> ${CONTEXT_DIR}/Dockerfile
    echo 'RUN  chown -R cyber-dojo ${CYBER_DOJO_KATAS_ROOT}' >> ${CONTEXT_DIR}/Dockerfile
    echo 'VOLUME [ "${CYBER_DOJO_KATAS_ROOT}" ]' >> ${CONTEXT_DIR}/Dockerfile
    echo 'CMD [ "katas-data-container" ]' >> ${CONTEXT_DIR}/Dockerfile
    local TAG=cyberdojo/katas
    # create a katas volume - it is mounted into the web container
    # using a volumes_from in docker-compose.yml
    docker build \
              --build-arg=CYBER_DOJO_KATAS_ROOT=${CYBER_DOJO_ROOT}/katas \
              --tag=${TAG} \
              --file=${CONTEXT_DIR}/Dockerfile \
              ${CONTEXT_DIR} > /dev/null
    docker create \
              --name ${CYBER_DOJO_KATAS_DATA_CONTAINER} \
              ${TAG} \
              echo 'cdfKatasDC' > /dev/null
  fi
}

one_time_creation_of_katas_data_volume

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose --file ${my_dir}/docker-compose.yml build
