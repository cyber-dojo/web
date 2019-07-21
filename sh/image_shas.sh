#!/bin/bash
set -e

image_sha()
{
  docker run --rm cyberdojo/$1:latest sh -c 'echo -n ${SHA}'
}

image_tag()
{
  local -r sha=$(image_sha $1)
  echo ${sha:0:7}
}

tag_image()
{
  docker tag cyberdojo/$1:latest cyberdojo/$1:$(image_tag $1)
}

export_sha()
{
  export CYBER_DOJO_$(up_name $1)_SHA=$(image_sha $1)
}

export_tag()
{
  export CYBER_DOJO_$(up_name $1)_TAG=$(image_tag $1)
}

up_name()
{
    echo ${1} | tr a-z A-Z
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
