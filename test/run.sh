#!/bin/bash
set -e

# Fakes/Mocks saver writes to Dir.tmpdir
rm -rf /tmp/cyber-dojo

# The server-test directories, all of which run together. client is not one of
# them: those tests drive the served app end-to-end, from run_client.sh.
test_dirs=(
  lib
  models
  services
  controllers
)

coverage_dir=/tmp/cyber-dojo/coverage
mkdir -p "${coverage_dir}"
# clear out old coverage stats
rm -rf "${coverage_dir}/.resultset.json"
test_log="${coverage_dir}/test.log"

export COVERAGE_ROOT=${coverage_dir}
export RACK_ENV=test
export RUBYOPT='-W2 --enable-frozen-string-literal'

# Every test directory runs in ONE ruby process, so there is a single resultset
# and a single coverage report spanning the whole of source/.
testFiles=()
for test_dir in ${test_dirs[*]}
do
  testFiles+=(${test_dir}/*_test.rb)
done

# run-the-tests!
set +e
ruby -e "(%w( ./coverage.rb ) + %w( ${testFiles[*]} ).shuffle).map{ |file| require './'+file }" \
  -- "$@" 2>&1 | tee "${test_log}"
# Exit with ruby's status, not tee's, which always succeeds.
ruby_status=${PIPESTATUS[0]}
set -e

# Running the tests and judging the run are separate steps, as they are in the
# sibling repos: bin/check_test_metrics.sh and bin/check_coverage_metrics.sh
# read the json this run writes. A filtered run writes metrics describing only
# the tests it loaded, so gating it would say nothing about the suite.
exit "${ruby_status}"
