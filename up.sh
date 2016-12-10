#!/bin/bash
set -e
set -x

# You must do a down so the up brings up a new web container
#cyber-dojo down
#cyber-dojo up
#sleep 2

echo "A"

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

echo "B"

export CYBER_DOJO_ROOT=/usr/src/cyber-dojo
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

echo "C"

one_time_creation_of_katas_data_volume()
{
echo "E"
  # The katas data-volume is not created as a named volume because
  # it predates that docker feature.
  docker ps --all | grep -s ${CYBER_DOJO_KATAS_DATA_CONTAINER} > /dev/null
echo "F"
  if [ $? != 0 ]; then
echo "G"
    local CONTEXT_DIR=/tmp/build-katas-data-container
echo "H"
    mkdir -p ${CONTEXT_DIR}
    echo '*' > ${CONTEXT_DIR}/.dockerignore
echo "I"
    echo 'FROM alpine:3.4' > ${CONTEXT_DIR}/Dockerfile
echo "J"
    echo 'RUN adduser -D -H -u 19661 cyber-dojo' >> ${CONTEXT_DIR}/Dockerfile
    echo 'ARG CYBER_DOJO_KATAS_ROOT' >> ${CONTEXT_DIR}/Dockerfile
    echo 'USER root' >> ${CONTEXT_DIR}/Dockerfile
    echo 'RUN  mkdir -p ${CYBER_DOJO_KATAS_ROOT}' >> ${CONTEXT_DIR}/Dockerfile
    echo 'RUN  chown -R cyber-dojo ${CYBER_DOJO_KATAS_ROOT}' >> ${CONTEXT_DIR}/Dockerfile
    echo 'VOLUME [ "${CYBER_DOJO_KATAS_ROOT}" ]' >> ${CONTEXT_DIR}/Dockerfile
    echo 'CMD [ "katas-data-container" ]' >> ${CONTEXT_DIR}/Dockerfile
echo "K"
    local TAG=cyberdojo/katas
    # create a katas volume - it is mounted into the web container
    # using a volumes_from in docker-compose.yml
echo "L"
    docker build \
              --build-arg=CYBER_DOJO_KATAS_ROOT=${CYBER_DOJO_ROOT}/katas \
              --tag=${TAG} \
              --file=Dockerfile \
              ${CONTEXT_DIR} > /dev/null
echo "M"
    docker create \
              --name ${CYBER_DOJO_KATAS_DATA_CONTAINER} \
              ${TAG} \
              echo 'cdfKatasDC' > /dev/null
echo "N"
  fi
}

echo "D"

one_time_creation_of_katas_data_volume

echo "O"

docker-compose --file ${my_dir}/docker-compose.yml up -d

