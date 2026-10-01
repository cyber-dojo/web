#!/bin/bash
set -e

# Fakes/Mocks saver writes to Dir.tmpdir
rm -rf /tmp/cyber-dojo

coverage_dir=/tmp/cyber-dojo/coverage
mkdir -p "${coverage_dir}"
# clear out old coverage stats
rm -rf "${coverage_dir}/.resultset.json"
test_log="${coverage_dir}/test.log"

export COVERAGE_ROOT=${coverage_dir}
export RACK_ENV=test
export RUBYOPT='-W2 --enable-frozen-string-literal'

# Every server test, however deeply nested, so a new directory under server/
# runs without being named anywhere. The browser tests are not under server/:
# they drive the served app end-to-end, from run_client.sh.
#
# They all run in ONE ruby process, so there is a single resultset and a single
# coverage report spanning the whole of source/.
mapfile -t testFiles < <(find server -name '*_test.rb' | sort)

# run-the-tests!
set +e
# $stdout.sync = true keeps the progress dots appearing as the tests run. The
# pipe into tee makes ruby's stdout block-buffered, which would hold the dots
# back until the process exits.
ruby -e "\$stdout.sync = true; (%w( ./coverage.rb ) + %w( ${testFiles[*]} ).shuffle).map{ |file| require './'+file }" \
  -- "$@" 2>&1 | tee "${test_log}"
# Exit with ruby's status, not tee's, which always succeeds.
ruby_status=${PIPESTATUS[0]}
set -e

# Running the tests and judging the run are separate steps, as they are in the
# sibling repos: bin/check_test_metrics.sh and bin/check_coverage_metrics.sh
# read the json this run writes. A filtered run writes metrics describing only
# the tests it loaded, so gating it would say nothing about the suite.
exit "${ruby_status}"
