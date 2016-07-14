#!/bin/bash

# Assumes
# o) docker is installed
# o) bundle install has run
# o) current user can run docker commands without sudo
# o) start-points repos are in dir $1

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
root_dir=${my_dir}/..
repo_root=${1:-/Users/jonjagger/repos}

rm -f ${root_dir}/caches/*.json

export CYBER_DOJO_LANGUAGES_ROOT=${repo_root}/start-points-languages
export CYBER_DOJO_EXERCISES_ROOT=${repo_root}/start-points-exercises
export CYBER_DOJO_CUSTOM_ROOT=${repo_root}/start-points-custom

export CYBER_DOJO_KATAS_ROOT=${root_dir}/katas

export CYBER_DOJO_SHELL_CLASS=HostShell
export CYBER_DOJO_DISK_CLASS=HostDisk
export CYBER_DOJO_LOG_CLASS=StdoutLog
export CYBER_DOJO_GIT_CLASS=HostGit
export CYBER_DOJO_KATAS_CLASS=HostDiskKatas

export CYBER_DOJO_RUNNER_CLASS=DockerTarPipeRunner
export CYBER_DOJO_RUNNER_SUDO=''
export CYBER_DOJO_RUNNER_TIMEOUT=10

rails s $*
