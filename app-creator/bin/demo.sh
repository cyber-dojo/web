#!/usr/bin/env bash
set -Eeu

# Brings up a full, working cyber-dojo demo: creator + web (and the services
# they route to) behind the REAL cyber-dojo nginx, so you can create a
# group/kata in creator and then edit it in web.
#
# The browser tests use the same real nginx, with the /creator/ rate limit
# turned up so a run of page loads does not trip it. The demo keeps
# production's rate limits.
#
# Usage: app-creator/bin/demo.sh [--no-browser]

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/app-creator/bin"
source "${BIN_DIR}/copy_in_saver_test_data.sh"
source "${BIN_DIR}/curlers.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/lib.sh"

# Fail fast if docker is missing or its daemon is down: echo_env_vars below runs
# the versioner container, and a stopped daemon otherwise surfaces much later as
# api_demo reaching an empty CYBER_DOJO_CREATOR_PORT.
exit_non_zero_unless_installed docker
exit_non_zero_unless_docker_running

# Suppress "requested image's platform does not match host platform" warnings on Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64
# shellcheck disable=SC2046
export $(echo_env_vars)

# lib.sh runs this demo as its own compose project (COMPOSE_PROJECT_NAME), so it
# can run alongside the web and dashboard demos. nginx is the only service
# published to the host, on an overridable port, eg:
#   CYBER_DOJO_NGINX_HOST_PORT=91 app-creator/bin/demo.sh
# The default host port is unique per app (web=80, creator=81, dashboard=82)
# so each app's demo can run at the same time without overriding the port.
export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-81}"

# The demo serves every app this repo holds from the images their own make
# targets built from this commit (the Makefile's creator_demo depends on them),
# not from the published images versioner names, so one change (eg to shared
# CSS) shows up in all of them at once.
export CYBER_DOJO_DASHBOARD_IMAGE=244531986313.dkr.ecr.eu-central-1.amazonaws.com/dashboard
export CYBER_DOJO_DASHBOARD_TAG="$(get_image_tag)"
export CYBER_DOJO_WEB_IMAGE=244531986313.dkr.ecr.eu-central-1.amazonaws.com/web
export CYBER_DOJO_WEB_TAG="$(get_image_tag)"

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
# A quick smoke-test of the creator server's endpoints/pages. The requests run
# inside the creator container (see curlers.sh), NOT through nginx, whose
# /creator/ rate limit (zone=creator_choose, 60r/m burst 10) this burst of GETs
# would reach.
api_demo()
{
  echo
  curl_json_body_200 GET alive
  curl_json_body_200 GET ready
  curl_json_body_200 GET sha
  echo
  curl_200 home   'Content-Type: text/html'
  curl_200 choose_problem 'Content-Type: text/html'
  curl_200 choose_custom_problem 'Content-Type: text/html'
  curl_200 choose_ltf?exercise_name=Fizz%20Buzz 'Content-Type: text/html'
  echo
  curl_200 enter    'Content-Type: text/html'
  curl_200 avatar?id=5rTJv5   'Content-Type: text/html'
  curl_200 reenter?id=5U2J18  'Content-Type: text/html'
  curl_200 full?id=k5ZTk0     'Content-Type: text/html'
  echo
}

# - - - - - - - - - - - - - - - - - - - - - - -
# Tear down any previous demo.
docker --log-level=ERROR compose down --remove-orphans 2>/dev/null || true

# Bringing up the real nginx cascades (via depends_on) to web, creator,
# differ, dashboard and the services they need - ie the full demo stack.
# --wait blocks until the containers are healthy (creator etc. have a
# HEALTHCHECK) so the api_demo requests below don't race the booting servers.
docker --log-level=ERROR compose up --no-build --detach --wait --wait-timeout 180 nginx

copy_in_saver_test_data
api_demo

if [ "${1:-}" = '--no-browser' ]; then
  docker --log-level=ERROR compose down --remove-orphans
else
  # nginx rewrites '/' to /creator/home with a relative 301 (absolute_redirect
  # off), so the browser follows it while keeping this host port.
  open "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}"
fi
