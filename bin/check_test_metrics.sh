#!/usr/bin/env bash
set -Eeu

show_help()
{
  cat <<'EOF'
Usage: bin/check_test_metrics.sh [OPTIONS]

Checks the test metrics of the last test run against the limits in
test/test_metrics_params.json, printing each metric and its verdict, and exiting
non-zero if any limit is breached.

Reads reports/test_metrics.json, which 'make test_server' writes. This script
does not run the tests, so run them first.

Options:
  -h    Show this help

Example:
  make test_server
  bin/check_test_metrics.sh
EOF
}

while getopts 'h' option; do
  case "${option}" in
    h) show_help; exit 0 ;;
    *) show_help; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

readonly BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/lib.sh"
export $(echo_env_vars)

check_metrics test
