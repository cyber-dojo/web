#!/bin/sh

if [ "${CYBER_DOJO_SCRIPT_WRAPPER}" = "" ]; then
  echo "Do not call this script directly. Use cyber-dojo (no .sh) instead"
  exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure katas-data-container exists.
# o) if it doesn't and /var/www/cyber-dojo/katas exists on the host
#    then assume it holds practice sessions and _copy_ them into the new katas-data-container.
# o) if it doesn't and /var/www/cyber-dojo/katas does not exist on the host
#    then create new _empty_ katas-data-container

KATAS_ROOT=/var/www/cyber-dojo/katas
KATAS_DATA_CONTAINER=cdf-katas-DATA-CONTAINER

docker ps --all | grep --silent ${KATAS_DATA_CONTAINER}
if [ $? != 0 ]; then
  # determine appropriate Dockerfile (to create katas-data-container)
  if [ -d "${KATAS_ROOT}" ]; then
    echo "copying ${KATAS_ROOT} into new ${KATAS_DATA_CONTAINER}"
    SUFFIX=copied
    CONTEXT_DIR=${KATAS_ROOT}
  else
    echo "creating new empty ${KATAS_DATA_CONTAINER}"
    SUFFIX=empty
    CONTEXT_DIR=.
  fi

  # extract appropriate Dockerfile from web image
  KATAS_DOCKERFILE=${CONTEXT_DIR}/Dockerfile
  CID=$(docker create ${DOCKER_HUB_USERNAME}/${SERVER_NAME})
  docker cp ${CID}:${CYBER_DOJO_HOME}/app/docker/katas/Dockerfile.${SUFFIX} \
            ${KATAS_DOCKERFILE}
  docker rm -v ${CID} > /dev/null

  # 3. extract appropriate .dockerignore from web image
  KATAS_DOCKERIGNORE=${CONTEXT_DIR}/.dockerignore
  CID=$(docker create ${DOCKER_HUB_USERNAME}/${SERVER_NAME})
  docker cp ${CID}:${CYBER_DOJO_HOME}/app/docker/katas/Dockerignore.${SUFFIX} \
            ${KATAS_DOCKERIGNORE}
  docker rm -v ${CID} > /dev/null

  # use Dockerfile to build image
  TAG=${DOCKER_HUB_USERNAME}/katas
  docker build \
           --build-arg=CYBER_DOJO_KATAS_ROOT=${CYBER_DOJO_HOME}/katas \
           --tag=${TAG} \
           --file=${KATAS_DOCKERFILE} \
           ${CONTEXT_DIR}

  # use image to create data-container
  docker create \
         --name ${KATAS_DATA_CONTAINER} \
         ${TAG} \
         echo 'cdfKatasDC'

  rm KATAS_DOCKERFILE
  rm KATAS_DOCKERIGNORE
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_rb() {
  docker run \
    --rm \
    --user=root \
    --env=DOCKER_VERSION=${DOCKER_VERSION} \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    ${DOCKER_HUB_USERNAME}/${SERVER_NAME} \
    ${CYBER_DOJO_HOME}/app/docker/cyber-dojo.rb $1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_create() {
  local name=$1
  local url=$2
  cyber_dojo_rb "volume create --name=${name} --git=${url}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_exists() {
  docker volume ls | grep --silent "${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_down() {
  ${DOCKER_COMPOSE_CMD} down
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_sh() {
  # cdf-web name is from docker-compose.yml file
  docker exec --interactive --tty cdf-web sh
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

default_languages_volume=default_languages
default_exercises_volume=default_exercises
default_instructions_volume=default_instructions

cyber_dojo_up() {
  # process volume arguments
  local args=($*)
  for arg in "${args[@]}"
  do
    # eg exercises=james
    local name_volume=${arg}
    local name=$(echo ${name_volume} | cut -f1 -s -d=)
    local volume=$(echo ${name_volume} | cut -f2 -s -d=)

    if [ "${name}" = "languages" ] && [ "${volume}" != "" ]; then
      export CYBER_DOJO_LANGUAGES_VOLUME=${volume}
    fi

    if [ "${name}" = "exercises" ] && [ "${volume}" != "" ]; then
      export CYBER_DOJO_EXERCISES_VOLUME=${volume}
    fi

    if [ "${name}" = "instructions" ] && [ "${volume}" != "" ]; then
      export CYBER_DOJO_INSTRUCTIONS_VOLUME=${volume}
    fi

    #TODO: check if ${name} != languages/exercises/instructions
  done

  # create default volumes if necessary
  local github_jon_jagger='https://github.com/JonJagger'

  if [ "${CYBER_DOJO_LANGUAGES_VOLUME}" = "${default_languages_volume}" ]; then
    volume_exists ${default_languages_volume}
    if [ $? != 0 ]; then
      volume_create ${default_languages_volume} "${github_jon_jagger}/cyber-dojo-languages.git"
    fi
  fi

  if [ "${CYBER_DOJO_EXERCISES_VOLUME}" = "${default_exercises_volume}" ]; then
    volume_exists ${default_exercises_volume}
    if [ $? != 0 ]; then
      volume_create ${default_exercises_volume} "${github_jon_jagger}/cyber-dojo-refactoring-exercises.git"
    fi
  fi

  if [ "${CYBER_DOJO_INSTRUCTIONS_VOLUME}" = "${default_instructions_volume}" ]; then
    volume_exists ${default_instructions_volume}
    if [ $? != 0 ]; then
      volume_create ${default_instructions_volume} "${github_jon_jagger}/cyber-dojo-instructions.git"
    fi
  fi

  # check volumes exist
  volume_exists ${CYBER_DOJO_LANGUAGES_VOLUME}
  if [ $? != 0 ]; then
    echo "cyber-dojo volume languages=${CYBER_DOJO_LANGUAGES_VOLUME} does not exist"
    exit 1
  fi

  volume_exists ${CYBER_DOJO_EXERCISES_VOLUME}
  if [ $? != 0 ]; then
    echo "cyber-dojo volume exercises=${CYBER_DOJO_EXERCISES_VOLUME} does not exist"
    exit 1
  fi

  volume_exists ${CYBER_DOJO_INSTRUCTIONS_VOLUME}
  if [ $? != 0 ]; then
    echo "cyber-dojo volume instructions=${CYBER_DOJO_INSTRUCTIONS_VOLUME} does not exist"
    exit 1
  fi

  # bring up server with volumes
  echo "Using volume languages=${CYBER_DOJO_LANGUAGES_VOLUME}"
  echo "Using volume exercises=${CYBER_DOJO_EXERCISES_VOLUME}"
  echo "Using volume instructions=${CYBER_DOJO_INSTRUCTIONS_VOLUME}"

  ${DOCKER_COMPOSE_CMD} up -d
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# delegate to ruby script inside web container or web image

docker ps -all | grep --silent cdf-web
if [ $? = 0 ]; then
  # cdf-web name is from docker-compose.yml file
  docker exec cdf-web sh -c "${CYBER_DOJO_HOME}/app/docker/cyber-dojo.rb $@"
else
  cyber_dojo_rb "$*"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# set environment variables required by docker-compose.yml

export CYBER_DOJO_KATAS_CLASS=${CYBER_DOJO_KATAS_CLASS:=HostDiskKatas}
export CYBER_DOJO_SHELL_CLASS=${CYBER_DOJO_SHELL_CLASS:=HostShell}
export CYBER_DOJO_DISK_CLASS=${CYBER_DOJO_DISK_CLASS:=HostDisk}
export CYBER_DOJO_LOG_CLASS=${CYBER_DOJO_LOG_CLASS:=StdoutLog}
export CYBER_DOJO_GIT_CLASS=${CYBER_DOJO_GIT_CLASS:=HostGit}

export CYBER_DOJO_RUNNER_CLASS=${CYBER_DOJO_RUNNER_CLASS:=DockerTarPipeRunner}
export CYBER_DOJO_RUNNER_SUDO='sudo -u docker-runner sudo'
export CYBER_DOJO_RUNNER_TIMEOUT=${CYBER_DOJO_RUNNER_TIMEOUT:=10}

export CYBER_DOJO_LANGUAGES_VOLUME=${default_languages_volume}
export CYBER_DOJO_EXERCISES_VOLUME=${default_exercises_volume}
export CYBER_DOJO_INSTRUCTIONS_VOLUME=${default_instructions_volume}

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
DOCKER_COMPOSE_FILE=docker-compose.yml
DOCKER_COMPOSE_CMD="docker-compose --file=${MY_DIR}/${DOCKER_COMPOSE_FILE}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = "up" ]; then
  shift
  cyber_dojo_up $@
fi

if [ "$*" = "sh" ]; then
  cyber_dojo_sh
fi

if [ "$*" = "down" ]; then
  cyber_dojo_down
fi

