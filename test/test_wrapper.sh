#!/bin/bash

if [ "$#" -eq 0 ]; then
  echo
  echo '  How to use test_wrapper.sh'
  echo
  echo '  1. running specific tests in one folder'
  echo "     $ cd test/app_model"
  echo '     $ ./run.sh <ID*>'
  echo
  echo '  2. running all the tests in one folder'
  echo "     $ cd test/app_model"
  echo '     $ ./run.sh'
  echo
  echo '  3. running all the tests in all the folders'
  echo "     $ cd test"
  echo '     $ ./run.sh'
  echo
  exit
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
# check if tests alter the current git user!
# I don't want any confusion between the git repo created
# in a test (for an animal) and the main git repo of cyber-dojo!

gitUserNameBefore=`git config user.name`

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# set env-vars if not set

HOME_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"

export CYBER_DOJO_LOG_CLASS=MemoryLog

# Assumes repos for start-points et all are sibling folders to main repo folder
VAR=${CYBER_DOJO_LANGUAGES_ROOT:-${HOME_DIR}/../start-points-languages}
export CYBER_DOJO_LANGUAGES_ROOT=${VAR}

VAR=${CYBER_DOJO_EXERCISES_ROOT:-${HOME_DIR}/../start-points-exercises}
export CYBER_DOJO_EXERCISES_ROOT=${VAR}

VAR=${CYBER_DOJO_CUSTOM_ROOT:-${HOME_DIR}/../start-points-custom}
export CYBER_DOJO_CUSTOM_ROOT=${VAR}

VAR=${CYBER_DOJO_STORER_CLASS:-HostDiskStorer}
export CYBER_DOJO_STORER_CLASS=${VAR}

VAR=${CYBER_DOJO_SHELL_CLASS:-HostShell}
export CYBER_DOJO_SHELL_CLASS=${VAR}

VAR=${CYBER_DOJO_DISK_CLASS:-HostDisk}
export CYBER_DOJO_DISK_CLASS=${VAR}

VAR=${CYBER_DOJO_GIT_CLASS:-HostGit}
export CYBER_DOJO_GIT_CLASS=${VAR}

VAR=${CYBER_DOJO_RUNNER_TIMEOUT:=10}
export CYBER_DOJO_RUNNER_TIMEOUT=${VAR}

VAR=${CYBER_DOJO_RUNNER_SUDO:-''}
export CYBER_DOJO_RUNNER_SUDO=${VAR}

# ensure empty dirs exist
mkdir -p ${HOME_DIR}/caches

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
ruby ../print_coverage_percent.rb index.html $module | tee -a ${test_log}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gitUserNameAfter=`git config user.name`

if [ "$gitUserNameBefore" != "$gitUserNameAfter" ]; then
  echo --------------------------------------
  echo META TEST FAILURE!
  echo --------------------------------------
  echo Before
  echo '  $ git config user.name'
  echo "  $ $gitUserNameBefore"
  echo
  echo After
  echo '  $ git config user.name'
  echo "  $ $gitUserNameAfter"
  echo --------------------------------------
fi


