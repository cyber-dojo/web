#!/bin/bash
set -e

# https://github.com/cyber-dojo/inserter

docker run \
   --rm -it \
   --volume /var/run/docker.sock:/var/run/docker.sock \
   cyberdojo/inserter \
     test-web-storer
