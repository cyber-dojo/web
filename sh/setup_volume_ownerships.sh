#!/bin/bash
set -e

# TODO: the commands below are specific to DockerToolbox...
# if not on DockerToolbox then drop the docker-machine ssh
# How can you tell?

echo "setting ownership in porter"
docker-machine ssh default \
  'cd /tmp/id-map && sudo rm -rf * && sudo chown -R 19664 .'

echo "setting ownership in saver"
docker-machine ssh default \
  'cd /tmp/groups && sudo rm -rf * && sudo chown -R 19663 .'
docker-machine ssh default \
  'cd /tmp/katas  && sudo rm -rf * && sudo chown -R 19663 .'
