#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly SH_DIR="${ROOT_DIR}/sh"

export CYBER_DOJO_VERSIONER_TAG=${CYBER_DOJO_VERSIONER_TAG:-latest}
docker run --rm cyberdojo/versioner:${CYBER_DOJO_VERSIONER_TAG} \
  sh -c 'ruby /app/src/echo_env_vars.rb' > /tmp/versioner.web.env

set -a
. /tmp/versioner.web.env
set +a
# tests currently rely on LTFs outside languages-common
export CYBER_DOJO_LANGUAGES=cyberdojo/languages-all:d996783

"${SH_DIR}/docker_containers_down.sh"
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/copy_in_saver_test_data.sh" 2> /dev/null
if "${SH_DIR}/run_tests_in_container.sh" "$@"; then
  "${SH_DIR}/docker_containers_down.sh"
else
  exit 3
fi
