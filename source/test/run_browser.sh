#!/bin/bash
set -e

# Browser (Capybara + Selenium) tests, run as a SEPARATE script from run.sh.
# They drive the app end-to-end in the serving puma process (via Firefox in the
# selenium container), so the in-process SimpleCov line-coverage that run.sh
# enforces per module is not meaningful for them - hence they are kept out of
# run.sh's coverage loop and its coverage-summary gate.
#
# They still load through all.rb, which requires test_coverage.rb, so a
# COVERAGE_DIR and a module name (ARGV[0]) are set to satisfy that bootstrap;
# the resulting coverage report is simply not gated here. A test failure exits
# non-zero (minitest autorun), which bin/run_tests_in_container.sh propagates.

module=app_browser

coverage_dir=/tmp/cyber-dojo/coverage/${module}
mkdir -p "${coverage_dir}"
export COVERAGE_DIR=${coverage_dir}

# Same externals as run.sh: talk to the real saver container (so a kata created
# here is visible to the served app the browser loads), stub the runner.
export RACK_ENV=test
export CYBER_DOJO_SAVER_CLASS=SaverService
export CYBER_DOJO_RUNNER_CLASS=RunnerStub

export RUBYOPT='-W2 --enable-frozen-string-literal'

echo
echo "======${module}======"
cd "${module}"
testFiles=(*_test.rb)

ruby -e "(%w( ../test_coverage.rb ) + %w( ${testFiles[*]} ).shuffle).map{ |file| require './'+file }" \
  "${module}" "$@"
