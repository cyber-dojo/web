#!/bin/bash

# ensure Mocks saving to Dir.tmpdir have clean start
rm -rf /tmp/cyber-dojo-*

# run tests for each module
modules=( app_helpers app_lib app_models lib app_controllers )
#modules=( app_helpers ) does not leak volumes
modules=( app_lib ) # DOES leak volumes
#modules=( app_models ) does not leak volumes
#modules=( lib ) does not leak volumes
#modules=( app_controllers )
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
