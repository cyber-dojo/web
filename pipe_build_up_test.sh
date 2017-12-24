#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

${SH_DIR}/build_docker_image.sh
${SH_DIR}/docker_containers_up.sh
${SH_DIR}/../test/data/katas_old/tar_pipe_in.sh
${SH_DIR}/run_tests_in_container.sh ${*}
#${SH_DIR}/docker_containers_down.sh
