#!/bin/bash
set -e

image_sha()
{
  local -r name="${1}"
  docker run --rm cyberdojo/${name}:latest sh -c 'echo -n ${SHA}'
}

image_tag()
{
  local -r sha=$(image_sha $1)
  echo ${sha:0:7}
}

tag_image()
{
  local -r name="${1}"
  docker tag cyberdojo/${name}:latest cyberdojo/${name}:$(image_tag $1)
}

export_sha()
{
  local -r up_name=$(echo ${1} | tr a-z A-Z)
  export CYBER_DOJO_${up_name}_SHA=$(image_sha $1)
}

export_tag()
{
  local -r up_name=$(echo ${1} | tr a-z A-Z)
  export CYBER_DOJO_${up_name}_TAG=$(image_tag $1)
}

echo
if [ "${CYBER_DOJO_DIFFER_LOCAL}" = 'true' ]; then
  echo "Using local cyberdojo/differ:latest tagged to cyberdojo/differ:$(image_tag differ)"
  tag_image differ
  export_sha differ
  export_tag differ
fi

# tests currently rely on LTFs outside languages-common
export CYBER_DOJO_LANGUAGES=cyberdojo/languages-all:d996783
