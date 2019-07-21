#!/bin/bash
set -e

echo_sha()
{
  local -r container_name="test-web-${1}"
  local -r sha=$(docker exec ${container_name} sh -c 'echo ${SHA}')
  local -r tag=${sha:0:7}
  echo -e "${sha}    cyberdojo/${1}"
}

echo
for start_point in custom exercises languages; do
  echo_sha ${start_point}
done

echo
for service in differ mapper ragger runner saver; do
  echo_sha ${service}
done
