#!/bin/sh

if [ "${CYBER_DOJO_SCRIPT_WRAPPER}" = "" ]; then
  echo "Do not call this script directly. Use cyber-dojo (no .sh) instead"
  exit 1
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"
docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')

cyber_dojo_hub=cyberdojo
cyber_dojo_root=/usr/src/cyber-dojo

default_languages_volume=default-languages
default_exercises_volume=default-exercises
default_instructions_volume=default-instructions

# set environment variables required by docker-compose.yml

# important that data-root is not under app so any ruby files it might contain
# are *not* slurped by the rails web server as it starts!
export CYBER_DOJO_DATA_ROOT=${cyber_dojo_root}/data

export CYBER_DOJO_WEB_SERVER=${cyber_dojo_hub}/web:${docker_version}
export CYBER_DOJO_WEB_CONTAINER=cyber-dojo-web

export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_KATAS_ROOT=${cyber_dojo_root}/katas

export CYBER_DOJO_KATAS_CLASS=${CYBER_DOJO_KATAS_CLASS:=HostDiskKatas}
export CYBER_DOJO_SHELL_CLASS=${CYBER_DOJO_SHELL_CLASS:=HostShell}
export CYBER_DOJO_DISK_CLASS=${CYBER_DOJO_DISK_CLASS:=HostDisk}
export CYBER_DOJO_LOG_CLASS=${CYBER_DOJO_LOG_CLASS:=StdoutLog}
export CYBER_DOJO_GIT_CLASS=${CYBER_DOJO_GIT_CLASS:=HostGit}

export CYBER_DOJO_RUNNER_CLASS=${CYBER_DOJO_RUNNER_CLASS:=DockerTarPipeRunner}
export CYBER_DOJO_RUNNER_SUDO='sudo -u docker-runner sudo'
export CYBER_DOJO_RUNNER_TIMEOUT=${CYBER_DOJO_RUNNER_TIMEOUT:=10}

export CYBER_DOJO_RAILS_ENVIRONMENT=production
export CYBER_DOJO_LANGUAGES_VOLUME=default-languages
export CYBER_DOJO_EXERCISES_VOLUME=default-exercises
export CYBER_DOJO_INSTRUCTIONS_VOLUME=default-instructions

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
# volume_create
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

debug() {
  echo $1
  #:
}

g_tmp_dir=''
g_cidfile=''
g_cid=''
g_vol=''

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up() {
  local me='clean_up'
  if [ "${g_tmp_dir}" != '' ]; then
    debug "${me}: doing [rm -rf ${g_tmp_dir}]"
    rm -rf ${g_tmp_dir}
  else
    debug "{me}: g_tmp_dir='' -> NOT doing [rm]"
  fi

  if [ "${g_cidfile}" != '' ]; then
    debug "${me}: doing [rm ${g_cidfile}]"
    rm ${g_cidfile}
  else
    debug "${me}: g_cidfile='' -> NOT doing [rm]"
  fi

  if [ "${g_cid}" != '' ]; then
    debug "${me}: doing [docker rm -f ${g_cid}]"
    docker rm -f ${g_cid} > /dev/null 2>&1
  else
    debug "${me}: g_cid='' -> NOT doing [docker rm]"
  fi
  if [ "${g_vol}" != '' ]; then
    debug "${me}: doing [docker volume rm ${g_vol}]"
    # previous command seems to sometimes complete
    # before it is safe to remove its volume?!
    sleep 1
    docker volume rm ${g_vol}
  else
    debug "${me}: g_vol='' -> NOT doing [docker volume rm]"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run() {
  local me='run'
  local command=$*
  debug "${me}: command=${command}"
  eval ${command} > /dev/null 2>&1
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  if [ "${exit_status}" = 0 ]; then
    return 0
  else
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_create() {
  # cyber-dojo.rb has already processed the command line options but the
  # actual volume creation takes place _here_ and not inside cyber-dojo.rb
  # This is so it executes on the host and not inside a docker container.
  # This allows the --git=URL argument to specify a _local_ git repo (eg file:///...)
  # I also plan to add a --dir=PATH which will create a volume from a
  # regular _local_ dir.

  local vol=$1
  local url=$2
  echo "Creating ${vol} from ${url}"

  g_tmp_dir=`mktemp -d -t cyber-dojo.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary directory!"
    exit 1
  fi
  g_cidfile=`mktemp -t cyber-dojo.cid.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary file!"
    exit 1
  fi

  command="docker volume create --name=${vol} --label=cyber-dojo-volume=${url}"
  run "${command}" || (clean_up && exit 1)
  g_vol=${vol}

  command="git clone --depth=1 --branch=master ${url} ${g_tmp_dir}"
  run "${command}" || (clean_up && exit 1)

  # docker run --cid=cidfile requires that the cidfile does not already exist
  command="rm ${g_cidfile}"
  run "${command}" || (clean_up && exit 1)

  command="docker run --detach
               --cidfile=${g_cidfile}
               --interactive
               --net=none
               --user=root
               --volume=${vol}:/data
               ${CYBER_DOJO_WEB_SERVER} sh"
  run "${command}" || (clean_up && exit 1)

  g_cid=`cat ${g_cidfile}`

  # NB: [cp DIR/.] != [cp DIR];  DIR/. means copy the contents
  command="docker cp ${g_tmp_dir}/. ${g_cid}:/data"
  run "${command}" || (clean_up && exit 1)

  command="docker exec ${g_cid} sh -c 'cd /data && rm -rf .git'"
  run "${command}" || (clean_up && exit 1)

  command="docker exec ${g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run "${command}" || (clean_up && exit 1)

  command="docker exec ${g_cid} sh -c 'cd /usr/src/cyber-dojo/app/lib && ./check_setup_data.rb /data'"
  run "${command}" || (clean_up && exit 1)

  g_vol=''
  clean_up
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_exists() {
  # don't match a substring
  local start_of_line='^'
  local name=$1
  local end_of_line='$'
  docker volume ls --quiet | grep --silent "${start_of_line}${name}${end_of_line}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cyber_dojo_volume_create() {
  # cyber-dojo.rb has already been called to check arguments and print help
  for arg in $@
  do
    local name=$(echo ${arg} | cut -f1 -s -d=)
    local value=$(echo ${arg} | cut -f2 -s -d=)
    if [ "${name}" = '--name' ]; then
      local vol=${value}
    fi
    if [ "${name}" = '--git' ]; then
      local url=${value}
    fi
  done
  volume_create ${vol} ${url}
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
  # cyber-dojo.rb has already been called to check arguments and print help
  for arg in $@
  do
    local name=$(echo ${arg} | cut -f1 -s -d=)
    local value=$(echo ${arg} | cut -f2 -s -d=)
    # --env=development
    if [ "${name}" = "--env" ] && [ "${value}" = 'development' ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=development
    fi
    # --env=production
    if [ "${name}" = "--env" ] && [ "${value}" = 'production' ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=production
    fi
    # --env=test
    if [ "${name}" = "--env" ] && [ "${value}" = 'test' ]; then
      export CYBER_DOJO_RAILS_ENVIRONMENT=test
    fi
    # --languages=james
    if [ "${name}" = "--languages" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_LANGUAGES_VOLUME=${value}
    fi
    # --exercises=mike
    if [ "${name}" = "--exercises" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_EXERCISES_VOLUME=${value}
    fi
    # --instructions=olve
    if [ "${name}" = "--instructions" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_INSTRUCTIONS_VOLUME=${value}
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
    echo "FAILED: volume ${CYBER_DOJO_LANGUAGES_VOLUME} does not exist"
    exit 1
  fi
  if ! volume_exists ${CYBER_DOJO_EXERCISES_VOLUME}; then
    echo "FAILED: volume ${CYBER_DOJO_EXERCISES_VOLUME} does not exist"
    exit 1
  fi
  if ! volume_exists ${CYBER_DOJO_INSTRUCTIONS_VOLUME}; then
    echo "FAILED: volume ${CYBER_DOJO_INSTRUCTIONS_VOLUME} does not exist"
    exit 1
  fi

  echo "Using --environment=${CYBER_DOJO_RAILS_ENVIRONMENT}"
  echo "Using --languages=${CYBER_DOJO_LANGUAGES_VOLUME}"
  echo "Using --exercises=${CYBER_DOJO_EXERCISES_VOLUME}"
  echo "Using --instructions=${CYBER_DOJO_INSTRUCTIONS_VOLUME}"

  # bring up server with volumes
  ${docker_compose_cmd} up -d
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_container

cyber_dojo_rb "$*"

if [ $? != 0  ]; then
  exit 1
fi

if [ "$1" = 'volume' ] && [ "$2" = 'create' ]; then
  shift # volume
  shift # create
  cyber_dojo_volume_create "$@"
fi

if [ "$1" = 'up' ]; then
  shift # up
  cyber_dojo_up "$@"
fi

if [ "$1" = 'sh' ]; then
  cyber_dojo_sh
fi

if [ "$1" = 'down' ]; then
  cyber_dojo_down
fi
