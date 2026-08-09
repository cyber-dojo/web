#!/usr/bin/env bash
set -Eeu

show_help()
{
  cat <<'EOF'
Usage: bin/fetch_metrics_policy.sh [OPTIONS] <filename>

Downloads the rego policy that decides whether a metrics report is within the
limits in its params file, and writes it to <filename>.

The policy is shared, and lives in the kosli-attestation-types repo. Both this
repo's metrics checks and its CI workflow run it, and both obtain it by running
this script, so neither can end up judging by a different policy.

Exits non-zero, leaving no file behind, if the policy cannot be downloaded.

Options:
  -h    Show this help

Example:
  bin/fetch_metrics_policy.sh metrics-compliance.rego
EOF
}

while getopts 'h' option; do
  case "${option}" in
    h) show_help; exit 0 ;;
    *) show_help; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
  show_help
  exit 1
fi

readonly BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BIN_DIR}/lib.sh"

fetch_metrics_policy "${1}"
