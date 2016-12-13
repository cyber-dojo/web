#!/bin/bash
set -e

export CYBER_DOJO_HOME=/app
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
docker-compose --file ${my_dir}/docker-compose.yml build
