#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# collect trailing arguments to forward to tests

while (( "$#" )); do
  if [[ $1 == *.rb ]]; then
    testFiles+=($1)
    shift
  else
    args=($*)
    break
  fi
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# don't log to stdout
export CYBER_DOJO_LOG_CLASS=MemoryLog

# ensure caches dir exists and is empty
home_dir="$( cd "$( dirname "${0}" )/.." && pwd )"
rm -rf ${home_dir}/caches
mkdir -p ${home_dir}/caches

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#pwd                       # eg  .../cyber-dojo/test/app_lib
cwd=${PWD##*/}             # eg  app_lib

# clear out old coverage stats
coverage_dir=/tmp/cyber-dojo/${cwd}/coverage
mkdir -p ${coverage_dir}
rm -rf ${coverage_dir}/.resultset.json
test_log="${coverage_dir}/test.log"

# run-the-tests!
export COVERAGE_DIR=${coverage_dir}
ruby -e "%w( ${testFiles[*]} ).shuffle.map{ |file| './'+file }.each { |file| require file }" ${cwd} ${args[*]} 2>&1 | tee ${test_log}
ruby ../print_coverage_percent.rb ${coverage_dir}/index.html ${cwd} | tee -a ${test_log}
