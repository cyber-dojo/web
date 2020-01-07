#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SH_DIR="${ROOT_DIR}/sh"
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)
source "${SH_DIR}/set_image_tags.sh"
"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/copy_in_saver_test_data.sh" 2> /dev/null
"${SH_DIR}/run_tests_in_container.sh" "$@"
"${SH_DIR}/docker_containers_down.sh"
