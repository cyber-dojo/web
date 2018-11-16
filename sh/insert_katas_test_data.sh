#!/bin/bash
set -e
# https://github.com/cyber-dojo/inserter

readonly CONTAINER=${1:-test-web-storer}

docker run \
   --rm -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/inserter \
     ${CONTAINER}

# dup old new
