#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SH_DIR="${ROOT_DIR}/sh"

"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/tar_pipe_in.sh"
"${SH_DIR}/setup_volume_ownerships.sh"
if "${SH_DIR}/run_tests_in_container.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
else
  exit 1
fi
