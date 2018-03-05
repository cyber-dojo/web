#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

"${MY_DIR}"/sh/docker_containers_down.sh
"${MY_DIR}"/sh/build_docker_images.sh
"${MY_DIR}"/sh/docker_containers_up.sh
"${MY_DIR}"/test/data/katas_old/tar_pipe_into_storer.sh
if "${MY_DIR}"/sh/run_tests_in_container.sh "$@"; then
  "${MY_DIR}"/sh/docker_containers_down.sh
fi
