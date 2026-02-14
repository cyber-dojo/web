#!/bin/bash
set -e

# Fakes/Mocks saver writes to Dir.tmpdir
rm -rf /tmp/cyber-dojo

# Default is to run tests for all modules
modules=(
  lib
  app_models
  app_services
  app_controllers
)

# If module specified, only run its tests
for module in ${modules[*]}
do
  if [ "${module}" == "${1}" ]; then
    modules=("${1}")
    shift
    break
  fi
done

for module in ${modules[*]}
do
    echo
    echo "======${module}======"
    # clear out old coverage stats
    coverage_dir=/tmp/cyber-dojo/coverage/${module}
    mkdir -p "${coverage_dir}"
    rm -rf "${coverage_dir}/.resultset.json"
    test_log="${coverage_dir}/test.log"
    export COVERAGE_DIR=${coverage_dir}

    # set defaults for externals
    export CYBER_DOJO_SAVER_CLASS=SaverService
    export CYBER_DOJO_RUNNER_CLASS=RunnerStub

    # run-the-tests!
    cd "${module}"
    testFiles=(*_test.rb)

    export RUBYOPT='-W2 --enable-frozen-string-literal'

    ruby -e "(%w( ../test_coverage.rb ) + %w( ${testFiles[*]} ).shuffle).map{ |file| require './'+file }" \
      "${module}" "$@" 2>&1 | tee "${test_log}"

    ruby ../print_coverage_percent.rb "${module}" \
      | tee -a "${test_log}"

    cd ..
done

ruby ./print_coverage_summary.rb ${modules[*]}
exit $?
