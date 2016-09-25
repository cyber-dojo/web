#!/bin/sh

# This script delegate as much as possible to cyber-dojo.rb
# inside a web container. However, there are some commands it
# has to handle itself...
#
# 1. cyber-dojo start-point create
#       as the --git/--dir options can specify *local* paths
#
# 2. cyber-dojo up
#      relies on a *local* docker-compose.yml file
#
# 3. cyber-down down
#      relies on a *local* docker-compose.yml file
#

if [ "${CYBER_DOJO_SCRIPT_WRAPPER}" = "" ]; then
  echo "Do not call this script directly. Use cyber-dojo (no .sh) instead"
  exit 1
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker_compose_cmd="docker-compose --file=${my_dir}/docker-compose.yml"
docker_version=$(docker --version | awk '{print $3}' | sed '$s/.$//')

cyber_dojo_hub=cyberdojo
cyber_dojo_root=/usr/src/cyber-dojo

default_start_point_languages=languages
default_start_point_exercises=exercises
default_start_point_custom=custom

# set environment variables required by docker-compose.yml

export CYBER_DOJO_WEB_SERVER=${cyber_dojo_hub}/web:${docker_version}
export CYBER_DOJO_WEB_CONTAINER=cyber-dojo-web

export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER

export CYBER_DOJO_STORER_CLASS=${CYBER_DOJO_KATAS_CLASS:=HostDiskStorer}

export CYBER_DOJO_RUNNER_CLASS=${CYBER_DOJO_RUNNER_CLASS:=DockerTarPipeRunner}
export CYBER_DOJO_RUNNER_SUDO='sudo -u docker-runner sudo'
export CYBER_DOJO_RUNNER_TIMEOUT=${CYBER_DOJO_RUNNER_TIMEOUT:=10}

# start-points are held off CYBER_DOJO_ROOT/start_points/
# it's important they are not under app so any ruby files they might contain
# are *not* slurped by the rails web server as it starts!
export CYBER_DOJO_ROOT=${cyber_dojo_root}

export CYBER_DOJO_START_POINT_LANGUAGES=${default_start_point_languages}
export CYBER_DOJO_START_POINT_EXERCISES=${default_start_point_exercises}
export CYBER_DOJO_START_POINT_CUSTOM=${default_start_point_custom}

export CYBER_DOJO_RAILS_ENVIRONMENT=production

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

one_time_creation_of_katas_data_container() {
  # ensure katas-data-container exists.
  # o) if it doesn't and /var/www/cyber-dojo/katas exists on the host
  #    then assume it holds practice sessions from old server and _copy_ them
  #    into the new katas-data-container.
  # o) if it doesn't and /var/www/cyber-dojo/katas does not exist on the host
  #    then create new _empty_ katas-data-container
  local katas_root=/var/www/cyber-dojo/katas
  docker ps --all | grep -s ${CYBER_DOJO_KATAS_DATA_CONTAINER} > /dev/null
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
             --build-arg=CYBER_DOJO_KATAS_ROOT=${CYBER_DOJO_ROOT}/katas \
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

cyber_dojo_start_point_create() {
  # cyber-dojo.rb has already been called to check arguments and handle --help
  local start_point=$1
  shift
  for arg in $@
  do
    local name=$(echo ${arg} | cut -f1 -s -d=)
    local value=$(echo ${arg} | cut -f2 -s -d=)
    if [ "${name}" = '--git' ]; then
      local url=${value}
      start_point_create_git ${start_point} ${url}
    elif [ "${name}" = '--dir' ]; then
      local dir=${value}
      start_point_create_dir ${start_point} ${dir} ${dir}
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_create_git() {
  local start_point=$1
  local url=$2
  g_tmp_dir=`mktemp -d -t cyber-dojo.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary directory!"
    exit_fail
  fi
  # 1. clone git repo to local folder
  command="git clone --depth=1 --branch=master ${url} ${g_tmp_dir}"
  run "${command}" || clean_up_and_exit_fail "FAILED: git repo '${url}' does not exist"
  # 2. remove .git repo
  command="rm -rf ${g_tmp_dir}/.git"
  run "${command}" || clean_up_and_exit_fail
  # 3. delegate
  start_point_create_dir "${start_point}" "${g_tmp_dir}" "${url}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_create_dir() {
  local start_point=$1
  local dir=$2
  local src=$3
  g_cidfile=`mktemp -t cyber-dojo.cid.XXXXXX`
  if [ $? != 0 ]; then
    echo "FAILED: Could not create temporary file!"
    exit_fail
  fi
  # docker run --cid=cidfile requires that the cidfile does not already exist
  command="rm ${g_cidfile}"
  run "${command}" || clean_up_and_exit_fail

  # 1. make an empty docker volume
  command="docker volume create --name=${start_point} --label=cyber-dojo-start-point=${src}"
  run "${command}" || clean_up_and_exit_fail "FAILED: check command carefully"
  g_vol=${start_point}
  # 2. mount empty volume inside docker container
  command="docker run
               --detach
               --cidfile=${g_cidfile}
               --interactive
               --net=none
               --user=root
               --volume=${start_point}:/data
               ${CYBER_DOJO_WEB_SERVER} sh"
  run "${command}" || clean_up_and_exit_fail "FAILED: check command carefully"
  g_cid=`cat ${g_cidfile}`
  # 3. fill empty volume from local dir
  # NB: [cp DIR/.] != [cp DIR];  DIR/. means copy the contents
  command="docker cp ${dir}/. ${g_cid}:/data"
  run "${command}" || clean_up_and_exit_fail "FAILED: dir '${dir}' does not exist"
  # 4. ensure cyber-dojo user owns everything in the volume
  command="docker exec ${g_cid} sh -c 'chown -R cyber-dojo:cyber-dojo /data'"
  run "${command}" || clean_up_and_exit_fail
  # 5. check the volume is a good start-point
  command="docker exec ${g_cid} sh -c 'cd /usr/src/cyber-dojo/cli && ./start_point_check.rb /data'"
  run_loud "${command}" || clean_up_and_exit_fail
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

clean_up_and_exit_fail() {
  echo $1
  clean_up
  exit_fail
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
  # Use 'echo $1' to debug. Use ':' to not debug
  #echo $1
  :
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

start_point_exists() {
  # don't match a substring
  local start_of_line='^'
  local start_point=$1
  local end_of_line='$'
  docker volume ls --quiet | grep -s "${start_of_line}${start_point}${end_of_line}"
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# $ ./cyber-dojo up
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

cyber_dojo_up() {
  # cyber-dojo.rb has already been called to check arguments and handle --help
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
    # --languages=start-point
    if [ "${name}" = "--languages" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_LANGUAGES=${value}
    fi
    # --exercises=start-point
    if [ "${name}" = "--exercises" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_EXERCISES=${value}
    fi
    # --custom=start-point
    if [ "${name}" = "--custom" ] && [ "${value}" != '' ]; then
      export CYBER_DOJO_START_POINT_CUSTOM=${value}
    fi
  done
  # create default start-points if necessary
  local github_cyber_dojo='https://github.com/cyber-dojo'
  if [ "${CYBER_DOJO_START_POINT_LANGUAGES}" = "${default_start_point_languages}" ]; then
    if ! start_point_exists ${default_start_point_languages}; then
      echo "Creating start-point ${default_start_point_languages} from ${github_cyber_dojo}/start-points-languages.git"
      start_point_create_git ${default_start_point_languages} "${github_cyber_dojo}/start-points-languages.git"
    fi
  fi
  if [ "${CYBER_DOJO_START_POINT_EXERCISES}" = "${default_start_point_exercises}" ]; then
    if ! start_point_exists ${default_start_point_exercises}; then
      echo "Creating start-point ${default_start_point_exercises} from ${github_cyber_dojo}/start-points-exercises.git"
      start_point_create_git ${default_start_point_exercises} "${github_cyber_dojo}/start-points-exercises.git"
    fi
  fi
  if [ "${CYBER_DOJO_START_POINT_CUSTOM}" = "${default_start_point_custom}" ]; then
    if ! start_point_exists ${default_start_point_custom}; then
      echo "Creating start-point ${default_start_point_custom}  from ${github_cyber_dojo}/start-points-custom.git"
      start_point_create_git ${default_start_point_custom} "${github_cyber_dojo}/start-points-custom.git"
    fi
  fi
  # check volumes exist
  if ! start_point_exists ${CYBER_DOJO_START_POINT_LANGUAGES}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_LANGUAGES} does not exist"
    exit_fail
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_EXERCISES}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_EXERCISES} does not exist"
    exit_fail
  fi
  if ! start_point_exists ${CYBER_DOJO_START_POINT_CUSTOM}; then
    echo "FAILED: start-point ${CYBER_DOJO_START_POINT_CUSTOM} does not exist"
    exit_fail
  fi
  echo "Using start-point --languages=${CYBER_DOJO_START_POINT_LANGUAGES}"
  echo "Using start-point --exercises=${CYBER_DOJO_START_POINT_EXERCISES}"
  echo "Using start-point --custom=${CYBER_DOJO_START_POINT_CUSTOM}"
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

if [ "$1" = 'start-point' ] && [ "$2" = 'create' ]; then
  shift # start-point
  shift # create
  cyber_dojo_start_point_create "$@"
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
