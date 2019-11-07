#!/bin/bash

cat_env_vars()
{
  # use from bash script like this:
  #   source cat_env_vars.sh
  #   readonly TAG=${1:-latest}
  #   export $(cat_env_vars ${TAG})
  local -r tag=${1}
  docker run --rm cyberdojo/versioner:${tag} \
    sh -c 'cat /app/.env'
}

export -f cat_env_vars
