#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: bin/copy_out_saver_data.sh

Snapshots the running saver container's /cyber-dojo directory into
test/data/saver_data.v2.tgz. Run this after creating demo data with
bin/create_group_kata.sh to persist it for future demo runs.

The saver container of the running demo must be up.
See bin/create_group_kata.sh -h for the full step-by-step workflow.
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed docker

readonly SRC_DIR=/cyber-dojo
readonly DST_TGZ_FILENAME="${ROOT_DIR}/test/data/saver_data.v2.tgz"
readonly CONTAINER="$(service_container saver)"

# extract /cyber-dojo from container into tgz file
docker exec "${CONTAINER}" \
  tar -zcf - -C $(dirname ${SRC_DIR}) $(basename ${SRC_DIR}) \
    > "${DST_TGZ_FILENAME}"
