
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
stderr()
{
  >&2 echo "${1}"
}
