#!/usr/bin/env bash
set -Eeu

containers_up()
{
  echo
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    --progress=plain \
    up \
    --detach \
    --no-build \
    --wait \
    --wait-timeout=10 \
    web runner saver
}
