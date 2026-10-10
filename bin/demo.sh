#!/usr/bin/env bash
set -Eeu

# Brings up the one local demo of all three apps (web, creator, dashboard)
# behind the real cyber-dojo nginx, as a single compose project with a single
# saver holding every app's demo data, so any page can be compared with any
# other. Runs the images the Makefile's demo prerequisites built from HEAD.

show_help()
{
  cat <<- 'HELP'
	Usage: bin/demo.sh [-h] [count]

	Brings up the demo stack (compose project 'demo', nginx on port 80),
	loads the demo data into its saver, creates a fresh v2 kata with
	[count] test runs (default 1), smoke-tests it through nginx, then
	opens the dashboard demo group, the demo cluster and the new kata.

	Options:
	  -h    Show this help

	Example:
	  make demo count=5
	  bin/demo.sh 5
	HELP
}

if [ "${1:-}" = '-h' ]; then
  show_help
  exit 0
fi

repo_root() { git rev-parse --show-toplevel; }
readonly COUNT="${1:-1}"
readonly DATA_DIR="$(repo_root)/app-dashboard/test/data"

stderr() { >&2 echo "ERROR: ${1}"; }
exit_non_zero() { exit 42; }

exit_non_zero_unless_installed()
{
  # Fails fast, naming the missing tool, rather than far downstream.
  for dependent in "$@"
  do
    printf "Checking %s is installed..." "${dependent}"
    if ! hash "${dependent}" &> /dev/null; then
      stderr "${dependent} is not installed"
      exit_non_zero
    else
      echo It is
    fi
  done
}

exit_non_zero_unless_docker_running()
{
  # 'docker' being installed (on the PATH) does not mean its daemon is up, and
  # a stopped daemon otherwise surfaces later as an empty env-var because the
  # versioner container never ran. 'docker info' fails fast if it is down.
  printf "Checking the docker daemon is running..."
  if ! docker info > /dev/null 2>&1 ; then
    stderr "the docker daemon is not running"
    exit_non_zero
  else
    echo It is
  fi
}

exit_non_zero_unless_installed docker ruby curl
exit_non_zero_unless_docker_running

# The pinned tags of every service the stack depends on (from versioner).
source "$(repo_root)/app-web/bin/echo_env_vars.sh"
# shellcheck disable=SC2046
export $(echo_env_vars)

export COMPOSE_PROJECT_NAME=demo
export CYBER_DOJO_NGINX_HOST_PORT=80

# The three apps run the images their make targets just built from HEAD, so
# one change (eg to shared CSS) shows up in all of them at once.
readonly HEAD_TAG="$(git -C "$(repo_root)" rev-parse HEAD | head -c7)"
export CYBER_DOJO_WEB_IMAGE=244531986313.dkr.ecr.eu-central-1.amazonaws.com/web
export CYBER_DOJO_WEB_TAG="${HEAD_TAG}"
export CYBER_DOJO_CREATOR_IMAGE=cyberdojo/creator
export CYBER_DOJO_CREATOR_TAG="${HEAD_TAG}"
export CYBER_DOJO_DASHBOARD_IMAGE=244531986313.dkr.ecr.eu-central-1.amazonaws.com/dashboard
export CYBER_DOJO_DASHBOARD_TAG="${HEAD_TAG}"

demo_compose()
{
  # Runs docker compose over the files the demo's up and down share, so down
  # removes everything up started.
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    "$@"
}

service_container()
{
  # Echoes the container id of the given service in the demo project.
  docker ps \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
    --filter "label=com.docker.compose.service=${1}" \
    --format '{{.ID}}'
}

copy_in_demo_data()
{
  # Loads every app's demo groups, katas and the demo cluster into the saver.
  # saver_data.v2.tgz holds every id in the three apps' test/data/cyber-dojo
  # dirs as well as the dashboard demo group, and the three tgz files share no
  # ids. The saver's /cyber-dojo is a tmpfs, which docker cp cannot write to,
  # and piping each tgz straight in keeps macOS's case-insensitive filesystem
  # from merging case-distinct dirs (eg katas/Ks and katas/ks). The dashboard
  # data's timestamps are rewritten to now so its pages look like a live
  # session.
  local -r saver="$(service_container saver)"
  local -r rewrite="$(repo_root)/app-dashboard/bin/rewrite_demo_timestamps.rb"
  echo "Loading demo data into the saver"
  ruby "${rewrite}" < "${DATA_DIR}/saver_data.v2.tgz" \
    | docker exec -i "${saver}" tar --no-xattrs -zxf - -C /
  ruby "${rewrite}" < "${DATA_DIR}/saver_cluster.v2.tgz" \
    | docker exec -i "${saver}" tar --no-xattrs -zxf - -C /
  docker exec -i "${saver}" tar xz -C / \
    < "$(repo_root)/app-creator/test/data/full_group.FD6ryx.tgz"
}

demo_url()
{
  # Echoes the URL of the given path on the demo's nginx.
  echo "http://localhost:${CYBER_DOJO_NGINX_HOST_PORT}/${1}"
}

curl_200()
{
  # Fails the demo, showing the response, unless a GET of the given path
  # returns 200 with a body containing the given pattern.
  local -r path="${1}"
  local -r pattern="${2}"
  local -r log="$(mktemp)"
  printf "\tGET /%s => 200 ...|%s " "${path}" "${pattern}"
  local code
  code="$(curl --silent --output "${log}" --write-out '%{http_code}' \
    --header 'Accept: application/json' \
    --header 'X-Requested-With: XMLHttpRequest' \
    "$(demo_url "${path}")" || true)"
  if [ "${code}" = 200 ] && grep --quiet "${pattern}" "${log}"; then
    echo SUCCESS
    rm "${log}"
  else
    echo "FAILED (${code})"
    cat "${log}"
    rm "${log}"
    exit_non_zero
  fi
}

smoke_test()
{
  # A few GETs through nginx, one per app - few enough to stay under nginx's
  # /creator/ rate limit.
  local -r kata_id="${1}"
  echo "Smoke testing through nginx"
  curl_200 dashboard/alive 'alive'
  curl_200 dashboard/ready 'ready'
  curl_200 dashboard/sha "${HEAD_TAG}"
  curl_200 dashboard/show/zuejz2 'dashboard-page'
  curl_200 creator/alive 'alive'
  curl_200 "kata/edit/${kata_id}" "${kata_id}"
}

create_v2_kata()
{
  # Echoes the id of a new v2 kata with the given number of test runs.
  docker exec "$(service_container web)" \
    bash -c "ruby /web/source/script/create_v2_kata.rb ${1}"
}

# - - - - - - - - - - - - - - - - - - - - - - -
# Tear down only the demo project, leaving any other compose project (eg a
# test run's) untouched.
demo_compose down --remove-orphans --volumes

# up, not run, so nginx is an ordinary service of the project that down
# removes, rather than a one-off container left holding the host port.
# Bringing up nginx cascades (via depends_on) to the whole stack, and --wait
# blocks until every container is healthy.
demo_compose up --no-build --detach --wait --wait-timeout 180 nginx

copy_in_demo_data
readonly KATA_ID="$(create_v2_kata "${COUNT}")"
echo "v2 Kata ID=${KATA_ID}"
smoke_test "${KATA_ID}"

open "$(demo_url 'dashboard/show/zuejz2?auto_refresh=false&minute_columns=true')"
open "$(demo_url 'dashboard/show/vntRcc?auto_refresh=false&minute_columns=true')"
open "$(demo_url "kata/edit/${KATA_ID}")"
