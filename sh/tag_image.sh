#!/bin/bash -Ee

#- - - - - - - - - - - - - - - - - - - - - - - -
tag_image()
{
  local -r image="$(image_name)"
  local -r sha="$(image_sha)"
  local -r tag="${sha:0:7}"
  docker tag ${image}:latest "${image}:${tag}"
  echo "${sha}"
  echo "${tag}"
}

#- - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo cyberdojo/web
}

#- - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  docker run --rm "$(image_name):latest" sh -c 'echo ${SHA}'
}

#- - - - - - - - - - - - - - - - - - - - - - - -
tag_image
