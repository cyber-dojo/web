#!/usr/bin/env bash
set -Eeu

exit_non_zero_if_bad_base_image()
{
  # Called in setup job in .github/workflows/main.yml
  base_image="${1}"
  regex=":[a-z0-9]{7}@sha256:[a-z0-9]{64}$"
  if ! [[ ${base_image} =~ $regex ]]; then
    stderr "BASE_IMAGE must have a 7-digit short-sha tag and a full 64-digit digest, Eg"
    stderr " name  : cyberdojo/web-base"
    stderr " tag   : 559d354"
    stderr " digest: ddab9080cd0bbd8e976a18bdd01b37b66e47fe83b0db396e65dc3014bad17fd3"
    exit 42
  fi
}

exit_non_zero_unless_installed()
{
  printf "Checking ${1} is installed..."
  if ! installed "${1}" ; then
    stderr "ERROR: ${1} is not installed!"
    exit 42
  fi
  if [ "${1}" == docker ]; then
    set +e
    docker run --rm cyberdojo/versioner:latest > /tmp/cyber-dojo.env-vars 2>&1
    local -r STATUS=$?
    set -e
    if [ "${STATUS}" != "0" ]; then
      stderr ERROR: docker not working
      cat /tmp/cyber-dojo.env-vars
      exit 42
    fi
  fi
  echo It is
}

installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

stderr()
{
  >&2 echo "${1}"
}
