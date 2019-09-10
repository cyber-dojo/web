#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SH_DIR="${ROOT_DIR}/sh"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

# assume we want image tags from versioner:latest
docker run --rm \
  cyberdojo/versioner:${CYBER_DOJO_VERSIONER_TAG:-latest} \
    sh -c 'cat /app/.env' \
        > /tmp/versioner.web.env

set -a
source /tmp/versioner.web.env
set +a
source "${SH_DIR}/set_image_tags.sh"

"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/copy_in_saver_test_data.sh" 2> /dev/null
if "${SH_DIR}/run_tests_in_container.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
else
  exit 3
fi
