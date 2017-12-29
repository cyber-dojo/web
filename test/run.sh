#!/bin/bash
set -e

if [ ! -f /.dockerenv ]; then
  echo 'FAILED: test_wrapper.sh is being executed outside of docker-container.'
  exit 1
fi

# Mocks save to Dir.tmpdir
rm -rf /tmp/cyber-dojo

if [ "${CYBER_DOJO_TEST_MODULES}" == "" ]; then
  modules=(
    app_helpers
    app_lib
    app_models
    app_services
    lib
    app_controllers
  )
  modules=( app_services )
else
  modules=( ${CYBER_DOJO_TEST_MODULES} )
fi

for module in ${modules[*]}
do
    echo
    echo "======${module}======"
    # set defaults to _not_ use real services
    export CYBER_DOJO_RUNNER_CLASS=RunnerStub
    export CYBER_DOJO_STORER_CLASS=StorerFake
    # clear out old coverage stats
    coverage_dir=/tmp/cyber-dojo/coverage/${module}
    mkdir -p ${coverage_dir}
    rm -rf ${coverage_dir}/.resultset.json
    test_log="${coverage_dir}/test.log"
    export COVERAGE_DIR=${coverage_dir}
    # run-the-tests!
    cd ${module}
    testFiles=(*_test.rb)
    ruby -e "%w( ${testFiles[*]} ).shuffle.map{ |file| require './'+file }" \
      ${module} ${*} 2>&1 | tee ${test_log}
    ruby ../print_coverage_percent.rb \
      ${module}           | tee -a ${test_log}
    cd ..
done

ruby ./print_coverage_summary.rb ${modules[*]}
exit $?
