#!/bin/bash

if [ ! -f /.dockerenv ]; then
  echo 'FAILED: test_wrapper.sh is being executed outside of docker-container.'
  exit 1
fi

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

# don't create permanent katas
katas_root=/tmp/cyber-dojo/katas
mkdir -p ${katas_root}
export CYBER_DOJO_KATAS_ROOT=${katas_root}

# don't log to stdout
export CYBER_DOJO_LOG_CLASS=MemoryLog

# ensure caches dir exists
home_dir="$( cd "$( dirname "${0}" )/.." && pwd )"
mkdir -p ${home_dir}/caches

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run-the-tests!

rm -rf ../../coverage/.resultset.json
mkdir -p coverage
test_log='coverage/test.log'
# ensure Mocks saving to Dir.tmpdir have clean start
rm -rf ${TMPDIR}/cyber-dojo-*
ruby -e "%w( ${testFiles[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${args[*]} 2>&1 | tee ${test_log}
cp -R ../../coverage .
#pwd                       # eg  .../cyber-dojo/test/app_lib
cwd=${PWD##*/}             # eg  app_lib
module=${cwd/_//}          # eg  app/lib
ruby ../print_coverage_percent.rb index.html ${module} | tee -a ${test_log}
