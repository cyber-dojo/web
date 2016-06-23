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

# important data-root is not under app so any ruby files it might contain
# are *not* slurped by the rails web server as it starts!
export CYBER_DOJO_DATA_ROOT=${cyber_dojo_root}/data

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
    # extract appropriate .dockerignore from web image
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
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    ${CYBER_DOJO_WEB_SERVER} \
    ${cyber_dojo_root}/cli/cyber-dojo.rb $1
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo volume create
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

g_tmp_dir=''  # if this is not '' then clean_up [rm -rf]'s it
g_cidfile=''  # if this is not '' then clean_up [rm]'s it
g_cid=''      # if this is not '' then clean_up [docker rm]'s the container
g_vol=''      # if this is not '' then clean_up [docker volume rm]'s the volume

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
  volume_create_git ${vol} ${url}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_create_git() {
  # cyber-dojo.rb has already processed the command line options but the actual volume
  # creation takes place here in cyber-dojo.sh and not inside cyber-dojo.rb
  # This is so it executes on the _host_ and not inside a docker container.
  # This allows the --git=URL argument to specify a _local_ git repo (eg file:///...)
  local vol=$1
  local url=$2
  g_tmp_dir=`mktemp -d -t cyber-dojo.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary directory!"
    exit_fail
  fi
  # 1. clone git repo to local folder
  command="git clone --depth=1 --branch=master ${url} ${g_tmp_dir}"
  run "${command}" || (clean_up && exit_fail)
  # 2. remove .git repo
  command="rm -rf ${g_tmp_dir}/.git"
  run "${command}" || (clean_up && exit_fail)
  # 3. delegate
  volume_create_dir "${vol}" "${g_tmp_dir}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_create_dir() {
  local vol=$1
  local dir=$2
  g_cidfile=`mktemp -t cyber-dojo.cid.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary file!"
    exit_fail
  fi
  # docker run --cid=cidfile requires that the cidfile does not already exist
  command="rm ${g_cidfile}"
  run "${command}" || (clean_up && exit_fail)

  # 1. make an empty docker volume
  command="docker volume create --name=${vol} --label=cyber-dojo-volume=${url}"
  run "${command}" || (clean_up && exit_fail)
  g_vol=${vol}
  # 2. mount empty volume inside docker container
  command="docker run
               --detach
               --cidfile=${g_cidfile}
               --interactive
               --net=none
               --user=root
               --volume=${vol}:/data
               ${CYBER_DOJO_WEB_SERVER} sh"
  run "${command}" || (clean_up && exit_fail)
  g_cid=`cat ${g_cidfile}`
  # 3. fill empty volume from local dir
  # NB: [cp DIR/.] != [cp DIR];  DIR/. means copy the contents
  command="docker cp ${dir}/. ${g_cid}:/data"
  run "${command}" || (clean_up && exit_fail)
  # 4. ensure cyber-dojo user owns everything in the volume
  command="docker exec ${g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run "${command}" || (clean_up && exit_fail)
  # 5. check the volume's contents adhere to the API
  command="docker exec ${g_cid} sh -c 'cd /usr/src/cyber-dojo/cli && ./volume_check.rb /data'"
  run_loud "${command}" || (clean_up && exit_fail)
  # clean up everything used to create the volume, but not the volume itself
  g_vol=''
  clean_up
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

run() {
  local me='run'
  local command="$1"
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

run_loud() {
  local me='run_loud'
  local command="$1"
  debug "${me}: command=${command}"
  eval ${command} > /dev/null
  local exit_status=$?
  debug "${me}: exit_status=${exit_status}"
  if [ "${exit_status}" = 0 ]; then
    return 0
  else
    return 1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

clean_up() {
  local me='clean_up'
  # remove tmp_dir?
  if [ "${g_tmp_dir}" != '' ]; then
    debug "${me}: doing [rm -rf ${g_tmp_dir}]"
    rm -rf ${g_tmp_dir} > /dev/null 2>&1
  else
    debug "{me}: g_tmp_dir='' -> NOT doing [rm]"
  fi
  # remove cidfile?
  if [ "${g_cidfile}" != '' ]; then
    debug "${me}: doing [rm ${g_cidfile}]"
    rm -f ${g_cidfile} > /dev/null 2>&1
  else
    debug "${me}: g_cidfile='' -> NOT doing [rm]"
  fi
  # remove docker container?
  if [ "${g_cid}" != '' ]; then
    debug "${me}: doing [docker rm -f ${g_cid}]"
    docker rm -f ${g_cid} > /dev/null 2>&1
  else
    debug "${me}: g_cid='' -> NOT doing [docker rm]"
  fi
  # remove docker volume?
  if [ "${g_vol}" != '' ]; then
    debug "${me}: doing [docker volume rm ${g_vol}]"
    # previous [docker rm] command seems to sometimes complete
    # before it is safe to remove its volume?!
    sleep 1
    docker volume rm ${g_vol} > /dev/null 2>&1
  else
    debug "${me}: g_vol='' -> NOT doing [docker volume rm]"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

exit_fail() {
  exit 1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

debug() {
  #echo $1
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

volume_exists() {
  # don't match a substring
  local start_of_line='^'
  local name=$1
  local end_of_line='$'
  docker volume ls --quiet | grep --silent "${start_of_line}${name}${end_of_line}"
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo up
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

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
    # --languages=vol
    if [ "${name}" = "--languages" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_LANGUAGES_VOLUME=${value}
    fi
    # --exercises=vol
    if [ "${name}" = "--exercises" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_EXERCISES_VOLUME=${value}
    fi
    # --instructions=vol
    if [ "${name}" = "--instructions" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_INSTRUCTIONS_VOLUME=${value}
    fi
  done
  # create default volumes if necessary
  local github_cyber_dojo='https://github.com/cyber-dojo'
  if [ "${CYBER_DOJO_LANGUAGES_VOLUME}" = "${default_languages_volume}" ]; then
    if ! volume_exists ${default_languages_volume}; then
      echo "Creating ${default_languages_volume} from ${github_cyber_dojo}/default-languages.git"
      volume_create_git ${default_languages_volume} "${github_cyber_dojo}/default-languages.git"
    fi
  fi
  if [ "${CYBER_DOJO_EXERCISES_VOLUME}" = "${default_exercises_volume}" ]; then
    if ! volume_exists ${default_exercises_volume}; then
      echo "Creating ${default_exercises_volume} from ${github_cyber_dojo}/default-exercises.git"
      volume_create_git ${default_exercises_volume} "${github_cyber_dojo}/default-exercises.git"
    fi
  fi
  if [ "${CYBER_DOJO_INSTRUCTIONS_VOLUME}" = "${default_instructions_volume}" ]; then
    if ! volume_exists ${default_instructions_volume}; then
      echo "Creating ${default_instructions_volume}  from ${github_cyber_dojo}/default-instructions.git"
      volume_create_git ${default_instructions_volume} "${github_cyber_dojo}/default-instructions.git"
    fi
  fi
  # check volumes exist
  if ! volume_exists ${CYBER_DOJO_LANGUAGES_VOLUME}; then
    echo "FAILED: volume ${CYBER_DOJO_LANGUAGES_VOLUME} does not exist"
    exit_fail
  fi
  if ! volume_exists ${CYBER_DOJO_EXERCISES_VOLUME}; then
    echo "FAILED: volume ${CYBER_DOJO_EXERCISES_VOLUME} does not exist"
    exit_fail
  fi
  if ! volume_exists ${CYBER_DOJO_INSTRUCTIONS_VOLUME}; then
    echo "FAILED: volume ${CYBER_DOJO_INSTRUCTIONS_VOLUME} does not exist"
    exit_fail
  fi
  echo "Using --languages=${CYBER_DOJO_LANGUAGES_VOLUME}"
  echo "Using --exercises=${CYBER_DOJO_EXERCISES_VOLUME}"
  echo "Using --instructions=${CYBER_DOJO_INSTRUCTIONS_VOLUME}"
  echo "Using --environment=${CYBER_DOJO_RAILS_ENVIRONMENT}"

  # bring up server with volumes
  ${docker_compose_cmd} up -d
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo down
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cyber_dojo_down() {
  ${docker_compose_cmd} down
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo sh
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cyber_dojo_sh() {
  docker exec --interactive --tty ${CYBER_DOJO_WEB_CONTAINER} sh
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_container

cyber_dojo_rb "$*"

if [ $? != 0  ]; then
  exit_fail
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
