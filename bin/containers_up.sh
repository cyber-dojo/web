#!/usr/bin/env bash
set -Eeu

containers_up()
{
  echo
  # nginx is brought up too so the browser reaches the app the way production
  # does (browser -> nginx -> {web, saver}). The app_browser tests point Capybara
  # at nginx, so a browser-side fetch of /saver/... is proxied to saver - web
  # itself has no /saver route. --no-deps keeps the demo-only web dependencies
  # (creator/dashboard/differ, added by docker-compose-nginx.yml) out; the
  # services web really needs (runner, saver) are listed explicitly.
  # CYBER_DOJO_NGINX_HOST_PORT only satisfies the nginx ports mapping; the tests
  # reach nginx over the compose network, not via this host port.
  export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-9080}"
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    --progress=plain \
    up \
    --detach \
    --no-build \
    --no-deps \
    --wait \
    --wait-timeout=60 \
    web runner saver selenium nginx
}
