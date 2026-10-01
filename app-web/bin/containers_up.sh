#!/usr/bin/env bash
set -Eeu

# The services both suites need. web serves the app and hosts the test run;
# saver and spooler are real (the tests drive web's write path through the
# spooler to saver); runner is real too - RunnerServiceTest swaps RunnerStub
# out and asks the runner container to run tests.
readonly SHARED_SERVICES=(web runner saver spooler)

# Brings up only what the server tests drive. They are in-process Rack tests, so
# no browser and no proxy: nothing under test/server names nginx or selenium.
server_containers_up()
{
  containers_up "${SHARED_SERVICES[@]}"
}

# Brings up what the browser tests drive: the shared services, the selenium grid
# running Firefox, and nginx. The browser loads the app through nginx the way
# production does (browser -> nginx -> {web, saver}), so a browser-side fetch of
# /saver/... is proxied to saver - web itself has no /saver route.
client_containers_up()
{
  containers_up "${SHARED_SERVICES[@]}" selenium nginx \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose-selenium.yml"
}

# Brings up the named services, from the base compose files plus any extra
# --file arguments. Services are named explicitly and --no-deps keeps the
# demo-only web dependencies (creator/dashboard/differ, added by
# docker-compose-nginx.yml) out.
#
# Takes the service names first, then any --file pairs, so a caller reads as
# the services it wants followed by where the extra ones are defined.
containers_up()
{
  local services=()
  while [ $# -gt 0 ] && [ "${1}" != '--file' ]; do
    services+=("${1}")
    shift
  done

  echo
  # CYBER_DOJO_NGINX_HOST_PORT only satisfies the nginx ports mapping; the tests
  # reach nginx over the compose network, not via this host port. Exported even
  # when nginx is not being started, since docker-compose-nginx.yml is still
  # read when it is.
  export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-9080}"
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    "$@" \
    --progress=plain \
    up \
    --detach \
    --no-build \
    --no-deps \
    --wait \
    --wait-timeout=60 \
    "${services[@]}"
}
