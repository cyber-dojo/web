#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
. ${my_dir}/env_vars.sh

docker-compose --file ${my_dir}/docker-compose.yml build
