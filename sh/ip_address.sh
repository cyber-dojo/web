#!/usr/bin/env bash
set -Eeu

ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME:-}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    printf localhost
  fi
}
