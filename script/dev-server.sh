#!/bin/bash

# Run's a local rails-server.
# Assumes
# o) bundle install has run
# o) docker is installed
# o) some language-images have been pulled.

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
RUNNER=${1:-DockerTarPipeRunner}

pushd ${MY_DIR} > /dev/null
cd ..
HOME=${PWD}
popd > /dev/null

DATA_ROOT=${HOME}/data

export CYBER_DOJO_LANGUAGES_ROOT=${DATA_ROOT}/languages
export CYBER_DOJO_EXERCISES_ROOT=${DATA_ROOT}/exercises
export CYBER_DOJO_INSTRUCTIONS_ROOT=${DATA_ROOT}/instructions
export CYBER_DOJO_KATAS_ROOT=${DATA_ROOT}/katas

export CYBER_DOJO_SHELL_CLASS=HostShell
export CYBER_DOJO_DISK_CLASS=HostDisk
export CYBER_DOJO_LOG_CLASS=StdoutLog
export CYBER_DOJO_GIT_CLASS=HostGit
export CYBER_DOJO_KATAS_CLASS=HostDiskKatas

export CYBER_DOJO_RUNNER_CLASS=${RUNNER}
export CYBER_DOJO_RUNNER_SUDO=''
export CYBER_DOJO_RUNNER_TIMEOUT=10

rails s $*
