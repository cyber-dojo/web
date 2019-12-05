#!/bin/bash

cat_env_vars()
{
  # use from bash script like this:
  #   source cat_env_vars.sh
  #   export $(cat_env_vars)
  docker run --rm cyberdojo/versioner:latest \
    sh -c 'cat /app/.env'
}

export -f cat_env_vars
