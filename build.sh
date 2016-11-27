#!/bin/bash

hash docker 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker is not installed"
  exit 1
fi

hash docker-compose 2> /dev/null
if [ $? != 0 ]; then
  echo
  echo "docker-compose is not installed"
  exit 1
fi

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose --file ${my_dir}/docker-compose.yml build
