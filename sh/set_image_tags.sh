#!/bin/bash
set -e
# source this file to set image tags as required by
# web's docker-compose.yml file which has entries such as:
# services:
#   differ:
#     image: cyberdojo/ragger:${CYBER_DOJO_DIFFER_TAG}

env_sha()
{
  # as set from versioner's /app/.env file
  local -r sha_name=CYBER_DOJO_$(up_name $1)_SHA
  local -r sha=${!sha_name}
  echo ${sha}
}

image_sha()
{
  # sha of local image, could be WIP
  docker run --rm cyberdojo/$1:latest sh -c 'echo -n ${SHA}'
}

up_name()
{
    echo ${1} | tr a-z A-Z
}

set_image_tag()
{
  local -r sha_from_image=$(image_sha $1)
  local -r sha_from_env=$(env_sha $1)
  if [ "${sha_from_image}" = "${sha_from_env}" ]; then
    local -r tag=${sha_from_env:0:7}
    echo "versioner ${sha_from_env} cyberdojo/$1:${tag}"
  else
    local -r tag=${sha_from_image:0:7}
    docker tag cyberdojo/$1:latest cyberdojo/$1:${tag}
    echo "    LOCAL ${sha_from_image} cyberdojo/$1:${tag}"
  fi
  export CYBER_DOJO_$(up_name $1)_TAG=${tag}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# tests currently rely on LTFs outside languages-common
export CYBER_DOJO_LANGUAGES=cyberdojo/languages-all:d996783

echo
echo "versioner ${CYBER_DOJO_CUSTOM}"
echo "versioner ${CYBER_DOJO_EXERCISES}"
echo "versioner ${CYBER_DOJO_LANGUAGES}"

echo
for service in differ mapper ragger runner saver zipper; do
  set_image_tag ${service}
done
