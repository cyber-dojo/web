#!/bin/bash
set -e

echo "setting ownerships in porter and saver"
docker-machine ssh default 'cd /tmp/id-map && sudo rm -rf * && sudo chown -R 19664 .'
docker-machine ssh default 'cd /tmp/groups && sudo rm -rf * && sudo chown -R 19663 .'
docker-machine ssh default 'cd /tmp/katas  && sudo rm -rf * && sudo chown -R 19663 .'
