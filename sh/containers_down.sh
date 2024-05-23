#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  echo
  docker compose \
    --file "$(repo_root)/docker-compose.yml" \
    down \
    --remove-orphans
}
