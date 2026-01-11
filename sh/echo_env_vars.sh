#!/usr/bin/env bash
set -Eeu

echo_env_vars()
{
  # Set env-vars for this repo
  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  {
    echo "# This file is generated in sh/lib.sh echo_env_vars()"
    run_versioner | grep PORT
    echo CYBER_DOJO_PROMETHEUS=true
  } > "$(repo_root)/.env"

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
  #
  echo CYBER_DOJO_SAVER_SHA=e6518bd660d5ffa2a51da26e4dfffb8fb2d6612a
  echo CYBER_DOJO_SAVER_TAG=e6518bd
}

run_versioner()
{
  # Hide platform warnings
  docker run --rm cyberdojo/versioner >/tmp/log.stdout 2>/tmp/log.stderr
  cat /tmp/log.stdout
}

image_name()
{
  echo "${CYBER_DOJO_WEB_IMAGE}"
}

image_sha()
{
  cd "$(root_dir)" && git rev-parse HEAD
}

root_dir()
{
  git rev-parse --show-toplevel
}

image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}
