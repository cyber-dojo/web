#!/usr/bin/env bash
set -Eeu

# Run this after doing 'make dashboard_demo'

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

TYPE=server
SERVICE=dashboard
USER="${CYBER_DOJO_DASHBOARD_SERVER_USER}"

create_v2_dashboard_prep()
{
  docker compose --progress=plain up --no-build --wait --wait-timeout=10 "${SERVICE}"
  copy_in_saver_test_data
}

create_v2_dashboard()
{
  # Resolve the container now it is up; Compose namespaces it by project+service.
  local -r CONTAINER_NAME="$(service_container "${SERVICE}")"
  docker exec \
    --user "${USER}" \
    "${CONTAINER_NAME}" \
      sh -c "ruby /dashboard/test/scripts/create_v2_dashboard.rb"
}

create_v2_dashboard_prep
create_v2_dashboard 