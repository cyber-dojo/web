#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
cd ${my_dir}/../cli
echo 'Bringing cyber-dojo up'
./cyber-dojo up
echo 'Shelling into web container and running tests'
cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"
# TODO copy coverage out
done=$?
exit $done