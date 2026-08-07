#!/bin/bash
set -e

# Fakes/Mocks saver writes to Dir.tmpdir
rm -rf /tmp/cyber-dojo

# The unit-test directories, all of which run together. browser is not one of
# them: those tests drive the served app end-to-end, from run_browser.sh.
test_dirs=(
  lib
  models
  services
  controllers
)

# Every argument is a test-id prefix, which narrows the run.
filtered=false
if [ $# -gt 0 ]; then
  filtered=true
fi

coverage_dir=/tmp/cyber-dojo/coverage
mkdir -p "${coverage_dir}"
# clear out old coverage stats
rm -rf "${coverage_dir}/.resultset.json"
test_log="${coverage_dir}/test.log"

export COVERAGE_DIR=${coverage_dir}
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

# A filtered run loads only some of the test files, so its coverage figure says
# nothing about the suite as a whole. Gate full runs only.
if [ "${filtered}" == "true" ]; then
  echo
  echo "Filtered run - coverage not gated."
  exit "${ruby_status}"
fi

# The summary reads the log's minitest lines, which a crashed run may never have
# written, so a failed run reports its own status rather than the gate's.
if [ "${ruby_status}" -ne 0 ]; then
  exit "${ruby_status}"
fi

ruby ./print_coverage_summary.rb
exit $?
