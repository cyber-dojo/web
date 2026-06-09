#!/usr/bin/env bash
set -Eeu

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed docker


readonly SRC_DIR=/cyber-dojo
readonly DST_TGZ_FILENAME="${ROOT_DIR}/saver_data.tgz"
readonly SAVER_CID="$(service_container saver)"

# extract /cyber-dojo from container into tgz file
docker exec "${SAVER_CID}" \
  tar -zcf - -C $(dirname ${SRC_DIR}) $(basename ${SRC_DIR}) \
    > "${DST_TGZ_FILENAME}"
