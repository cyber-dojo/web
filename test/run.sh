#!/bin/bash

# Mocks save to Dir.tmpdir
rm -rf /tmp/cyber-dojo

modules=( app_helpers app_lib app_models lib app_controllers )
for module in ${modules[*]}
do
    echo
    echo "======${module}======"
    cd ${module}
    ../test_wrapper.sh *_test.rb ${*}
    cd ..
done

ruby ./print_coverage_summary.rb ${modules[*]}
exit $?
