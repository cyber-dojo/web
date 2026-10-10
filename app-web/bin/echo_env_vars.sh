#!/usr/bin/env bash
set -Eeu

# The absolute path of the repo's root directory. Defined here, rather than
# left to the sourcing script, so this file is self-sufficient: the functions
# below call it.
repo_root() { git rev-parse --show-toplevel; }

echo_env_vars()
{
  #--------------------
  # Set env-vars for this repo
  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  source "$(repo_root)/bin/write_dot_env.sh"
  write_dot_env

  # Get identities of all docker-compose.yml dependent services (from versioner)
  run_versioner
  #
  echo CYBER_DOJO_WEB_SHA="$(image_sha)"
  echo CYBER_DOJO_WEB_TAG="$(image_tag)"

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_WEB_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/web"

  # Here you can add SHA/TAG env-vars for any service whose
  # local repos you have edited, have new git commits in,
  # and have built new images from. Their build scripts
  # finish by printing echo env-var statements you need to
  # add to this function if you want the new images to be
  # part of the dev-loop/demo. For example:
  #
  # echo CYBER_DOJO_SAVER_SHA=fef7a58e2eb3c3b16c51ef0f2c71fc6b7bfb53af
  # echo CYBER_DOJO_SAVER_TAG=fef7a58
}

run_versioner()
{
  docker run --rm cyberdojo/versioner
}

image_name()
{
  echo "${CYBER_DOJO_WEB_IMAGE}"
}

image_sha()
{
  cd "$(repo_root)" && git rev-parse HEAD
}

image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}
