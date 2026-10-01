#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)
exit_non_zero_unless_installed snyk

IMAGE_NAME="${CYBER_DOJO_DASHBOARD_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG}"
JSON_FILE_OUTPUT="${ROOT_DIR}/snyk.container.scan.json"
POLICY_PATH="${ROOT_DIR}/.snyk"

snyk container test "${IMAGE_NAME}" \
  --json-file-output="${JSON_FILE_OUTPUT}" \
  --policy-path="${POLICY_PATH}"
