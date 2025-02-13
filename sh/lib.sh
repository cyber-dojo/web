#!/usr/bin/env bash
set -Eeu

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
