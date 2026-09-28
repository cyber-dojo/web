#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: dashboard/bin/demo_data.sh [traffic_light_count] [avatar_count]

  traffic_light_count  Approx test runs per avatar (default: 5)
  avatar_count         Approx avatars to join the group (default: 20)

Creates a new demo group kata in the running saver, snapshots the result
to dashboard/test/data/saver_data.v2.tgz, and writes the GID to
dashboard/test/data/demo_gid.txt.

Requires the demo stack to already be running (run 'make dashboard_demo' first).

Example:
  make dashboard_demo
  dashboard/bin/demo_data.sh 5 20
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

readonly LIGHT_COUNT="${1:-5}"
readonly AVATAR_COUNT="${2:-20}"

echo "Creating group kata (${AVATAR_COUNT} avatars, ~${LIGHT_COUNT} test runs each)..."
GID=$(docker exec --interactive "$(service_container saver)" ruby - "${LIGHT_COUNT}" "${AVATAR_COUNT}" \
  < "${ROOT_DIR}/bin/create_group_kata.rb")
readonly GID
echo "Created group: ${GID}"

echo "Saving saver data to test/data/saver_data.v2.tgz..."
bash "${ROOT_DIR}/bin/copy_out_saver_data.sh"

echo "${GID}" > "${ROOT_DIR}/test/data/demo_gid.txt"
echo "Done. Open: http://localhost/dashboard/show/${GID}?auto_refresh=true&minute_columns=true"
