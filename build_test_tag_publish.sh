#!/bin/bash -Eeu

readonly SH_DIR="$(cd "$(dirname "${0}")/sh" && pwd)"

source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)

"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/tag_image.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/copy_in_saver_test_data.sh" 2> /dev/null
"${SH_DIR}/run_tests_in_container.sh" "$@"
"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/on_ci_publish_tagged_images.sh"
