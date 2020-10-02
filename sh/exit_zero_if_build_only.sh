#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - - - -
exit_zero_if_build_only()
{
  if build_only_arg "${1:-}" ; then
    exit 0
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
build_only_arg()
{
  [ "${1:-}" == '--build-only' ] || [ "${1:-}" == '-bo' ]
}
