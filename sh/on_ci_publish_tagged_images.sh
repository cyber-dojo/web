#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  echo
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    echo
    return
  fi
  echo 'on CI so publishing tagged images'
  echo
  local -r image="$(image_name)"
  local -r sha="$(image_sha)"
  local -r tag=${sha:0:7}
  docker push ${image}:latest
  docker push ${image}:${tag}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}
