#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SH_DIR="${ROOT_DIR}/sh"

docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env' > /tmp/versioner.web.env
set -a
. /tmp/versioner.web.env
set +a
export CYBER_DOJO_LANGUAGES=cyberdojo/languages-all:d996783
export CYBER_DOJO_DIFFER_TAG=${CYBER_DOJO_DIFFER_SHA:0:7}
export CYBER_DOJO_MAPPER_TAG=${CYBER_DOJO_MAPPER_SHA:0:7}
export CYBER_DOJO_RAGGER_TAG=${CYBER_DOJO_RAGGER_SHA:0:7}
export CYBER_DOJO_RUNNER_TAG=${CYBER_DOJO_RUNNER_SHA:0:7}
export CYBER_DOJO_SAVER_TAG=${CYBER_DOJO_SAVER_SHA:0:7}
export CYBER_DOJO_ZIPPER_TAG=${CYBER_DOJO_ZIPPER_SHA:0:7}
export CYBER_DOJO_VERSIONER_TAG=${CYBER_DOJO_VERSIONER_TAG:-latest}

"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/copy_in_saver_test_data.sh" 2> /dev/null
if "${SH_DIR}/run_tests_in_container.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
else
  exit 3
fi
