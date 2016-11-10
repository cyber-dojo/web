#!/bin/bash

# ensure Mocks saving to Dir.tmpdir have clean start
rm -rf /tmp/cyber-dojo-*

# run tests for each module
modules=( app_helpers app_lib app_models lib app_controllers )
#modules=( app_lib )
for module in ${modules[*]}
do
    echo
    echo "======$module======"
    cd $module
    ./run.sh $*
    cd ..
done

./print_coverage_summary.rb ${modules[*]}
exit $?
