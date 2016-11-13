#!/bin/bash
set -e

cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"
