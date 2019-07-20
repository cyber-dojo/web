#!/bin/bash
set -e

sha()
{
  local -r container_name="test-web-${1}"
  local -r sha=$(docker exec ${container_name} sh -c 'echo ${SHA}')
  local -r tag=${sha:0:7}
  echo -e "${sha}    cyberdojo/${1}"
}

echo
sha custom
sha exercises
sha languages
echo
sha differ
sha mapper
sha ragger
sha runner
sha saver
