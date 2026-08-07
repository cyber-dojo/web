#!/bin/bash
set -e

# Browser (Capybara + Selenium) tests, run as a SEPARATE script from run.sh.
# They drive the app end-to-end in the serving puma process (via Firefox in the
# selenium container), so the in-process SimpleCov line-coverage that run.sh
# enforces is not meaningful for them - hence they are kept out of run.sh's
# coverage run and its coverage-summary gate.
#
# They load through all.rb, which starts SimpleCov only when COVERAGE_DIR is
# set, so setting none here leaves coverage unstarted. A test failure exits
# non-zero (minitest autorun), which bin/run_tests_in_container.sh propagates.

test_dir=browser

# Same externals as run.sh: talk to the real saver container (so a kata created
# here is visible to the served app the browser loads), stub the runner.
export RACK_ENV=test

export RUBYOPT='-W2 --enable-frozen-string-literal'

echo
echo "======${test_dir}======"
cd "${test_dir}"
testFiles=(*_test.rb)

ruby -e "%w( ${testFiles[*]} ).shuffle.map{ |file| require './'+file }" \
  "$@"
