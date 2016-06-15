#!/bin/sh

if [ "${CYBER_DOJO_SCRIPT_WRAPPER}" = "" ]; then
  echo "Do not call this script directly. Use cyber-dojo (no .sh) instead"
  exit 1
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"
docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')

cyber_dojo_hub=cyberdojofoundation
cyber_dojo_root=/usr/src/cyber-dojo

default_languages_volume=default-languages
default_exercises_volume=default-exercises
default_instructions_volume=default-instructions

default_rails_environment=production

# set environment variables required by docker-compose.yml

# important that data-root is not under app so any ruby files it might contain
# are *not* slurped by the web server as it starts!
export CYBER_DOJO_DATA_ROOT=${cyber_dojo_root}/data

export CYBER_DOJO_WEB_SERVER=${cyber_dojo_hub}/web:${docker_version}
export CYBER_DOJO_WEB_CONTAINER=cdf-web

export CYBER_DOJO_KATAS_DATA_CONTAINER=cdf-katas-DATA-CONTAINER
export CYBER_DOJO_KATAS_ROOT=${cyber_dojo_root}/katas

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

export CYBER_DOJO_RAILS_ENVIRONMENT=${default_rails_environment}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_container() {
  # ensure katas-data-container exists.
  # o) if it doesn't and /var/www/cyber-dojo/katas exists on the host
  #    then assume it holds practice sessions from old server and _copy_ them
  #    into the new katas-data-container.
  # o) if it doesn't and /var/www/cyber-dojo/katas does not exist on the host
  #    then create new _empty_ katas-data-container

  local katas_root=/var/www/cyber-dojo/katas

  docker ps --all | grep --silent ${CYBER_DOJO_KATAS_DATA_CONTAINER}
  if [ $? != 0 ]; then
    # determine appropriate Dockerfile (to create katas data container)
    if [ -d "${katas_root}" ]; then
      echo "copying ${katas_root} into new ${CYBER_DOJO_KATAS_DATA_CONTAINER}"
      SUFFIX=copied
      CONTEXT_DIR=${katas_root}
    else
      echo "creating new empty ${CYBER_DOJO_KATAS_DATA_CONTAINER}"
      SUFFIX=empty
      CONTEXT_DIR=.
    fi

    # extract appropriate Dockerfile from web image
    local katas_dockerfile=${CONTEXT_DIR}/Dockerfile
    local cid=$(docker create ${CYBER_DOJO_WEB_SERVER})
    docker cp ${cid}:${cyber_dojo_root}/docker/katas/Dockerfile.${SUFFIX} \
              ${katas_dockerfile}
    docker rm --volumes ${cid} > /dev/null

    # 3. extract appropriate .dockerignore from web image
    local katas_docker_ignore=${CONTEXT_DIR}/.dockerignore
    local cid=$(docker create ${CYBER_DOJO_WEB_SERVER})
    docker cp ${cid}:${cyber_dojo_root}/docker/katas/Dockerignore.${SUFFIX} \
              ${katas_docker_ignore}
    docker rm --volumes ${cid} > /dev/null

    # use Dockerfile to build image
    local tag=${cyber_dojo_hub}/katas
    docker build \
             --build-arg=CYBER_DOJO_KATAS_ROOT=${CYBER_DOJO_KATAS_ROOT} \
             --tag=${tag} \
             --file=${katas_dockerfile} \
             ${CONTEXT_DIR}

    # use image to create data-container
    docker create \
           --name ${CYBER_DOJO_KATAS_DATA_CONTAINER} \
           ${tag} \
           echo 'cdfKatasDC'

    rm ${katas_dockerfile}
    rm ${katas_docker_ignore}
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_rb() {
  docker run \
    --rm \
    --user=root \
    --env=CYBER_DOJO_HUB=${cyber_dojo_hub} \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    ${CYBER_DOJO_WEB_SERVER} \
    ${cyber_dojo_root}/docker/cyber-dojo.rb $1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_create() {
  local vol=$1
  local url=$2
  echo "Creating ${vol} from ${url}"
  cyber_dojo_rb "volume create --name=${vol} --git=${url}"
  if [ "$?" != "0" ]; then
    exit 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_exists() {
  # careful to not match substring
  local start_of_line='^'
  local name=$1
  local end_of_line='$'
  docker volume ls --quiet | grep --silent "${start_of_line}${name}${end_of_line}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_down() {
  ${docker_compose_cmd} down
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_sh() {
  docker exec --interactive --tty ${CYBER_DOJO_WEB_CONTAINER} sh
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_up() {
  # process volume arguments
  shift
  for arg in "$*"
  do
    local name=$(echo ${arg} | cut -f1 -s -d=)
    local value=$(echo ${arg} | cut -f2 -s -d=)

    # eg --env=production
    if [ "${name}" = "--env" ] && [ "${value}" = "development" ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=development
    fi
    if [ "${name}" = "--env" ] && [ "${value}" = "production" ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=production
    fi
    if [ "${name}" = "--env" ] && [ "${value}" = "test" ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=test
    fi

    # eg --languages=james
    if [ "${name}" = "--languages" ] && [ "value" != "" ]; then
      export CYBER_DOJO_LANGUAGES_VOLUME=value
    fi

    if [ "${name}" = "--exercises" ] && [ "value" != "" ]; then
      export CYBER_DOJO_EXERCISES_VOLUME=value
    fi

    if [ "${name}" = "--instructions" ] && [ "value" != "" ]; then
      export CYBER_DOJO_INSTRUCTIONS_VOLUME=value
    fi
  done

  # create default volumes if necessary
  local github_cyber_dojo='https://github.com/cyber-dojo'

  if [ "${CYBER_DOJO_LANGUAGES_VOLUME}" = "${default_languages_volume}" ]; then
    if ! volume_exists ${default_languages_volume}; then
      volume_create ${default_languages_volume} "${github_cyber_dojo}/default-languages.git"
    fi
  fi

  if [ "${CYBER_DOJO_EXERCISES_VOLUME}" = "${default_exercises_volume}" ]; then
    if ! volume_exists ${default_exercises_volume}; then
      volume_create ${default_exercises_volume} "${github_cyber_dojo}/default-exercises.git"
    fi
  fi

  if [ "${CYBER_DOJO_INSTRUCTIONS_VOLUME}" = "${default_instructions_volume}" ]; then
    if ! volume_exists ${default_instructions_volume}; then
      volume_create ${default_instructions_volume} "${github_cyber_dojo}/default-instructions.git"
    fi
  fi

  # check default/explicit volumes exist
  if ! volume_exists ${CYBER_DOJO_LANGUAGES_VOLUME}; then
    echo "volume ${CYBER_DOJO_LANGUAGES_VOLUME} does not exist"
    exit 1
  fi

  if ! volume_exists ${CYBER_DOJO_EXERCISES_VOLUME}; then
    echo "volume ${CYBER_DOJO_EXERCISES_VOLUME} does not exist"
    exit 1
  fi

  if ! volume_exists ${CYBER_DOJO_INSTRUCTIONS_VOLUME}; then
    echo "volume ${CYBER_DOJO_INSTRUCTIONS_VOLUME} does not exist"
    exit 1
  fi

  echo "Using rails --environment=${CYBER_DOJO_RAILS_ENVIRONMENT}"
  echo "Using volume --languages=${CYBER_DOJO_LANGUAGES_VOLUME}"
  echo "Using volume --exercises=${CYBER_DOJO_EXERCISES_VOLUME}"
  echo "Using volume --instructions=${CYBER_DOJO_INSTRUCTIONS_VOLUME}"
  # bring up server with volumes
  ${docker_compose_cmd} up -d
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_container

cyber_dojo_rb "$*"
if [ $? != 0  ]; then
  exit 1
fi

if [ "$1" = "up" ]; then
  cyber_dojo_up $@
fi

if [ "$1" = "sh" ]; then
  cyber_dojo_sh
fi

if [ "$1" = "down" ]; then
  cyber_dojo_down
fi

