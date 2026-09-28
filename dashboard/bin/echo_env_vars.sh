#!/usr/bin/env bash
set -Eeu

echo_env_vars()
{
  #--------------------
  # Set env-vars for this repo

  if [[ ! -v COMMIT_SHA ]] ; then
    echo COMMIT_SHA="$(image_sha)"  # --build-arg
  fi

  local -r env_filename="$(repo_root)/.env"
  {
    echo "# This file is generated in bin/lib.sh echo_env_vars()"
    run_versioner | grep PORT
    # The shared services read this file, so it must match what
    # web/bin/echo_env_vars.sh writes. Dashboard-only env-vars live in
    # dashboard/dashboard.env.
    echo CYBER_DOJO_SPOOLER_PORT=4539
    echo CYBER_DOJO_PROMETHEUS=true
  } > "${env_filename}"

  # Get identities of all docker-compose.yml dependent services (from versioner)
  run_versioner 

  echo CYBER_DOJO_DASHBOARD_SHA="$(image_sha)"
  echo CYBER_DOJO_DASHBOARD_TAG="$(image_tag)"

  echo CYBER_DOJO_DASHBOARD_CLIENT_IMAGE=cyberdojo/dashboard-client
  echo CYBER_DOJO_DASHBOARD_CLIENT_PORT=9999

  echo CYBER_DOJO_DASHBOARD_CLIENT_USER=nobody
  echo CYBER_DOJO_DASHBOARD_SERVER_USER=nobody

  local -r AWS_ACCOUNT_ID=244531986313
  local -r AWS_REGION=eu-central-1
  echo CYBER_DOJO_DASHBOARD_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/dashboard"

  # Here you can add SHA/TAG env-vars for any service whose
  # local repos you have edited, have new git commits in,
  # and have built new images from. Their build scripts
  # finish by printing echo env-var statements you need to
  # add to this function if you want the new images to be
  # part of the dev-loop/demo. For example:
  #
  # echo CYBER_DOJO_WEB_SHA=e49a0d92d8ec37f386545e503bc2dfc4bf9c1557
  # echo CYBER_DOJO_WEB_TAG=e49a0d9
}

run_versioner()
{
  # Hide platform warnings
  docker run --rm cyberdojo/versioner >/tmp/log.stdout 2>/tmp/log.stderr
  cat /tmp/log.stdout
}
