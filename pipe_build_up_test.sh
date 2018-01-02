#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

${MY_DIR}/sh/docker_containers_down.sh
${MY_DIR}/sh/build_docker_image.sh
${MY_DIR}/sh/docker_containers_up.sh
${MY_DIR}/test_katas_old/tar_pipe_into_storer.sh
${MY_DIR}/sh/run_tests_in_container.sh ${*}
if [ $? -eq 0 ]; then
  ${MY_DIR}/sh/docker_containers_down.sh
fi
