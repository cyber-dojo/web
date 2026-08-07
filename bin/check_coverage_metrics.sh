#!/usr/bin/env bash
set -Eeu

show_help()
{
  cat <<'EOF'
Usage: bin/check_coverage_metrics.sh [OPTIONS]

Checks the coverage metrics of the last test run against the limits in
test/coverage_metrics_limits.rb, printing each metric and its verdict, and
exiting non-zero if any limit is breached.

Reads reports/coverage_metrics.json, which 'make test' writes. This script
does not run the tests, so run them first.

Options:
  -h    Show this help

Example:
  make test
  bin/check_coverage_metrics.sh
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

readonly HOST_TEST_DIR="$(repo_root)/test"
readonly HOST_REPORTS_DIR="$(repo_root)/reports"
readonly CONTAINER_TMP_DIR=/tmp

exit_non_zero_unless_file_exists "${HOST_TEST_DIR}/check_metrics.rb"           # evaluator
exit_non_zero_unless_file_exists "${HOST_REPORTS_DIR}/coverage_metrics.json"   # data from the test run
exit_non_zero_unless_file_exists "${HOST_TEST_DIR}/coverage_metrics_limits.rb" # the limits

# Run the evaluator inside the app image, so it uses the same ruby the tests do.
docker run \
  --read-only \
  --rm \
  --entrypoint="" \
  --volume "${HOST_TEST_DIR}/check_metrics.rb:${CONTAINER_TMP_DIR}/check_metrics.rb:ro" \
  --volume "${HOST_REPORTS_DIR}/coverage_metrics.json:${CONTAINER_TMP_DIR}/coverage_metrics.json:ro" \
  --volume "${HOST_TEST_DIR}/coverage_metrics_limits.rb:${CONTAINER_TMP_DIR}/coverage_metrics_limits.rb:ro" \
    "${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}" \
      sh -c "ruby ${CONTAINER_TMP_DIR}/check_metrics.rb ${CONTAINER_TMP_DIR}/coverage_metrics.json coverage_metrics_limits"
