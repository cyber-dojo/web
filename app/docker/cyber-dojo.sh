#!/bin/sh

if [ "${CYBER_DOJO_SCRIPT_WRAPPER}" = "" ]; then
  echo "Do not call this script directly. Use cyber-dojo (no .sh) instead"
  exit 1
fi

# TODO: un-hardwire these
export CYBER_DOJO_DATA_ROOT="/home/docker/data"
export CYBER_DOJO_KATAS_ROOT="/home/docker/data/katas"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure CYBER_DOJO_KATAS_ROOT env-var is set

if [ -z "${CYBER_DOJO_KATAS_ROOT}" ]; then
    echo "CYBER_DOJO_KATAS_ROOT env-var is not set"
    KATAS_DATA_CONTAINER=cdf-katas-DATA-CONTAINER
    docker ps -a | grep -q ${KATAS_DATA_CONTAINER}
    if [ $? == 0 ]; then
      echo "${KATAS_DATA_CONTAINER} exists"
      echo 'to create a zipped, tar file of the katas inside it...'
      echo ''
      CMD="docker run \
            --user=root \
            --rm \
            --volumes-from=${KATAS_DATA_CONTAINER} \
            --volume=/tmp:/tmp \
            ${DOCKER_HUB_USERNAME}/${SERVER_NAME} \
            tar -cvz -f /tmp/katas.tgz -C ${CYBER_DOJO_HOME} katas"
      echo ${CMD}
      echo ''
      echo '  note: if you are in a Docker-Quickstart-Terminal this will'
      echo '        create /tmp/katas.tgz on the default VM. To ssh into default'
      echo '          docker-machine ssh default'

      echo 'to extract katas from /tmp/katas.tgz ...'
      echo 'tar -xvf /tmp/katas.tgz'
      CMD=""
      # TODO: show how to set CYBER_DOJO_KATAS_ROOT to folder untarred to
      # TODO: use tar pipe to create katas folder directly?

    fi
    # TODO: remove backup command from cyber-dojo.rb
    exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ensure CYBER_DOJO_DATA_ROOT env-var is set

if [ -z "${CYBER_DOJO_DATA_ROOT}" ]; then
    echo "CYBER_DOJO_DATA_ROOT env-var is not set"
    exit 1
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# delegate to ruby script inside web image

docker run \
  --rm \
  --user=root \
  --env=DOCKER_VERSION=${DOCKER_VERSION} \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --volume=${CYBER_DOJO_DATA_ROOT}/languages:${CYBER_DOJO_HOME}/app/data/languages:ro \
  ${DOCKER_HUB_USERNAME}/${SERVER_NAME} \
  ${CYBER_DOJO_HOME}/app/docker/cyber-dojo.rb $@

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# up/down/restart/sh

ME="./$( basename ${0} )"
MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

DOCKER_COMPOSE_CMD="docker-compose --file=${MY_DIR}/${DOCKER_COMPOSE_FILE}"

if [ "$*" = "up" ]; then
  ${DOCKER_COMPOSE_CMD} up -d
fi

if [ "$*" = "down" ]; then
  ${DOCKER_COMPOSE_CMD} down
fi

if [ "$*" = "restart" ]; then
  ${DOCKER_COMPOSE_CMD} down
  ${DOCKER_COMPOSE_CMD} up -d
fi

if [ "$*" = "sh" ]; then
  # cdf-web name is from docker-compose.yml file
  docker exec --interactive --tty cdf-web sh
fi

if [ "$1" = "exercises" ]; then
  NAME_URL=$2
  NAME=$(echo ${NAME_URL} | cut -f1 -s -d=)
  URL=$(echo ${NAME_URL} | cut -f2 -s -d=)
  if [ "${NAME}" = "" ] || [ "${URL}" = "" ]; then
    echo ./cyber-dojo exercises NAME=URL
    exit 1
  fi

  TMP_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
  CONTEXT_DIR=${TMP_DIR}/exercises
  git clone --depth 1 ${URL} ${CONTEXT_DIR}
  # build docker image
  cp ${MY_DIR}/Dockerfile   ${CONTEXT_DIR}
  cp ${MY_DIR}/.dockerignore ${CONTEXT_DIR}
  docker build \
          --build-arg=CYBER_DOJO_PATH=${CYBER_DOJO_HOME}/app/data/exercises \
          --tag=${NAME} \
          --file=${CONTEXT_DIR}/Dockerfile \
          ${CONTEXT_DIR}

  # build docker container
  docker create \
         --name ${NAME} \
         ${NAME} \
         echo "cdf ${NAME}-data-container"

  rm ${CONTEXT_DIR}/Dockerfile
  rm ${CONTEXT_DIR}/.dockerignore
fi

