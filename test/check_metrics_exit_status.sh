#!/usr/bin/env bash
set -Eeu

# Asserts that the metrics check says no when a bound is breached, and says so
# by exiting non-zero. A check that prints DENIED and exits 0 would leave every
# caller - make, CI - believing the metrics were within their limits.

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${TEST_DIR}/../bin/echo_env_vars.sh"
source "${TEST_DIR}/../bin/lib.sh"

readonly FIXTURES="${TEST_DIR}/check_metrics"
failures=0

assert_check_metrics()
{
  local -r name="${1}"
  local -r params="${2}"
  local -r expected_status="${3}"
  local -r expected_text="${4}"

  # Declared and assigned separately: combining them makes $? the status of
  # local, which is always 0, so no failure could ever be detected.
  local output
  local status
  set +e
  output="$(check_metrics_files "${FIXTURES}/report.json" "${FIXTURES}/${params}" 2>&1)"
  status=$?
  set -e

  if [ "${status}" != "${expected_status}" ] || [[ "${output}" != *"${expected_text}"* ]]; then
    stderr "FAIL: ${name}"
    stderr "  expected status ${expected_status}, got ${status}"
    stderr "  expected output containing: ${expected_text}"
    stderr "${output}"
    failures=$((failures + 1))
  fi
}

assert_check_metrics \
  'bounds the report meets' \
  params_met.json \
  0 \
  'ALLOWED'

assert_check_metrics \
  'a max bound below the reported value' \
  params_breached.json \
  1 \
  'code.branches.missed is 3, above its maximum of 2'

exit $((failures == 0 ? 0 : 1))
