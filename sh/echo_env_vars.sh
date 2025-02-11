#!/usr/bin/env bash
set -Eeu

echo_base_image()
{
  # This is set to the env-var BASE_IMAGE which is set as a docker compose build --build-arg
  # and used the Dockerfile's 'FROM ${BASE_IMAGE}' statement
  # This BASE_IMAGE abstraction is to facilitate the base_image_trigger.yml workflow.
  local -r json="$(curl --fail --silent --request GET https://beta.cyber-dojo.org/web/base_image)"
  local -r via_curl="$(echo "${json}" | jq -r '.base_image')"
  local -r via_code="cyberdojo/web-base:ec9ffc9@sha256:be3b6c61c36e6a266217521e65f1496a11e4184438f020c78135f9c543effc5e"
  if [ "${via_curl}" != "${via_code}" ] ; then
    stderr "BASE_IMAGE sources disagree"
    stderr "Via curl: '${via_curl}'"
    stderr "Via code: '${via_code}'"
    exit 42
  else
    echo "${via_code}"
  fi
}

echo_env_vars()
{
  # Set env-vars for this repo
  if [[ ! -v BASE_IMAGE ]] ; then
    echo BASE_IMAGE="$(echo_base_image)"  # --build-arg
  fi
  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  local -r env_filename="$(repo_root)/.env"
  echo CYBER_DOJO_PROMETHEUS=true > "${env_filename}"
  docker run --rm cyberdojo/versioner | grep PORT >> "${env_filename}"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  docker run --rm cyberdojo/versioner:latest
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
  # part of the demo. For example:
  #
  # echo CYBER_DOJO_SAVER_SHA=3203fa65b8fbb90023ae104fe259a93432de2681
  # echo CYBER_DOJO_SAVER_TAG=3203fa6
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
