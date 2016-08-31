#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

cd ${my_dir}/../docker/web-base
./build-image.sh

cd ${my_dir}/../docker/web
./build-image.sh

cd ${my_dir}/../cli
./cyber-dojo start-point ls --quiet | grep 'languages' && ./cyber-dojo start-point rm languages
./cyber-dojo start-point ls --quiet | grep 'exercises' && ./cyber-dojo start-point rm exercises
./cyber-dojo start-point ls --quiet | grep 'custom'    && ./cyber-dojo start-point rm custom
./cyber-dojo start-point ls

./cyber-dojo start-point create languages --dir=./../../start-points-languages
./cyber-dojo start-point create exercises --dir=./../../start-points-exercises
./cyber-dojo start-point create custom    --dir=./../../start-points-custom
./cyber-dojo start-point ls

./cyber-dojo up

cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh"
done=$?

exit $done