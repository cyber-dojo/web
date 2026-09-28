#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: dashboard/bin/create_group_kata.sh [traffic_light_count] [avatar_count]

  traffic_light_count  Approx number of red/amber/green cycles per avatar (default: 3)
  avatar_count         Approx number of avatars to join the group (default: 16)

Creates a bash/bats FizzBuzz group kata in the running saver, prints the group ID (GID).

To create new demo data and persist it:
----------------------------------------
1. Start the demo:
     make dashboard_demo

2. Create and save new demo data (runs this script, copies out tgz, updates GID):
     make dashboard_demo_data

3. Commit the updated tgz and demo.sh.
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed ruby

readonly traffic_light_count="${1:-3}"
readonly avatar_count="${2:-16}"
ruby "${ROOT_DIR}/bin/create_group_kata.rb" "${traffic_light_count}" "${avatar_count}"
