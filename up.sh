#!/bin/bash
set -e

# You must do a down so the up brings up a new web container
#cyber-dojo down
#cyber-dojo up
#sleep 2

export CYBER_DOJO_ROOT=/usr/src/cyber-dojo
export CYBER_DOJO_KATAS_DATA_CONTAINER=cyber-dojo-katas-DATA-CONTAINER
export CYBER_DOJO_START_POINT_LANGUAGES=languages
export CYBER_DOJO_START_POINT_EXERCISES=exercises
export CYBER_DOJO_START_POINT_CUSTOM=custom

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

docker-compose --file ${my_dir}/docker-compose.yml up -d

