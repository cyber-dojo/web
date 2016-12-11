#!/bin/bash

# Mocks save to Dir.tmpdir
# Also test/test_wrapper.sh sets CYBER_DOJO_KATAS_ROOT
# to /tmp/cyber-dojo/katas
# Ensure both have a clean start

rm -rf /tmp/cyber-dojo

modules=( app_helpers app_lib app_models lib app_controllers )
modules=( app_controllers )
for module in ${modules[*]}
do
    echo
    echo "======${module}======"
    cd ${module}
    ./run.sh ${*}
    cd ..
done

ruby ./print_coverage_summary.rb ${modules[*]}
exit $?
