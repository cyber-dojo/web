#!/usr/bin/env bash
set -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    down \
    --remove-orphans
}
