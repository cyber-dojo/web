#!/usr/bin/env bash
set -Eeu

echo_base_image()
{
  # This is set to the env-var BASE_IMAGE which is set as a [docker compose build] --build-arg
  # and used the Dockerfile's 'FROM ${BASE_IMAGE}' statement
  # This BASE_IMAGE abstraction is to facilitate the base_image_update.yml workflow
  # which is an work-in-progress experiment to look into automating deployment to the staging environment
  # (https://beta.cyber-dojo.org) of a Dockerfile base-image update (eg to fix snyk vulnerabilities).
  echo_base_image_via_curl
  # echo_base_image_via_code
}

echo_base_image_via_curl()
{
  local -r json="$(curl --fail --silent --request GET https://beta.cyber-dojo.org/web/base_image)"
  echo "${json}" | jq -r '.base_image'
}

echo_base_image_via_code()
{
  # An alternative echo_base_image for local development.
  local -r tag=c617fee
  local -r digest=ded8fe228c99f13f0496a7f696d619c8a3f1fd7c9c4020a3fd8442b6d5841617
  echo "cyberdojo/web-base:${tag}@sha256:${digest}"
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
