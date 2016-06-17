#!/bin/bash

# Assumes
# o) docker is installed
# o) bundle install has run
# o) some language-images have been pulled
# o) current user can run docker commands without sudo
# o) setup data is in local git repos

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

ROOT_DIR=${MY_DIR}/..

rm ${ROOT_DIR}/caches/*.json

REPO_ROOT=${1:-/Users/jonjagger/repos}

export CYBER_DOJO_LANGUAGES_ROOT=${REPO_ROOT}/default-languages
export CYBER_DOJO_EXERCISES_ROOT=${REPO_ROOT}/default-exercises
export CYBER_DOJO_INSTRUCTIONS_ROOT=${REPO_ROOT}/default-instructions

export CYBER_DOJO_KATAS_ROOT=${ROOT_DIR}/katas

export CYBER_DOJO_SHELL_CLASS=HostShell
export CYBER_DOJO_DISK_CLASS=HostDisk
export CYBER_DOJO_LOG_CLASS=StdoutLog
export CYBER_DOJO_GIT_CLASS=HostGit
export CYBER_DOJO_KATAS_CLASS=HostDiskKatas

export CYBER_DOJO_RUNNER_CLASS=DockerTarPipeRunner
export CYBER_DOJO_RUNNER_SUDO=''
export CYBER_DOJO_RUNNER_TIMEOUT=10

rails s $*
