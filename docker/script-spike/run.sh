#!/bin/sh

./build-image.sh

docker volume rm jj

./new-cyber-dojo start-point create jj --dir=/Users/jonjagger/repos/start-points-custom

docker volume ls | grep jj