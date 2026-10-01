#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export COVERAGE_ROOT="${1}" # /tmp/coverage
readonly TEST_LOG="${2}"    # test.log
readonly TYPE="${3}"        # client|server
shift; shift; shift

readonly TEST_FILES=(${MY_DIR}/${TYPE}/*_test.rb)
readonly TEST_ARGS=(${@})

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

mkdir -p "${COVERAGE_ROOT}"

set +e
export RUBYOPT='-W2 --enable-frozen-string-literal'
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${COVERAGE_ROOT}/${TEST_LOG}
# Exit with ruby's status, not tee's. A suite whose metrics are not pinned has
# nothing else to report a failure: tee always succeeds.
readonly RUBY_STATUS=${PIPESTATUS[0]}
set -e

# The log is complete now, so turn the part of it that is a metric into data the
# gate can read. See test/log_metrics.rb.
ruby "${MY_DIR}/log_metrics.rb" \
  "${COVERAGE_ROOT}/${TEST_LOG}" \
  "${COVERAGE_ROOT}/log_metrics.json"

exit "${RUBY_STATUS}"
