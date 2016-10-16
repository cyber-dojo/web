#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
${my_dir}/../build-image.sh
${my_dir}/../../commander/cyber-dojo up

echo 'Shelling into web container and running tests'
cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"
# TODO copy coverage out
done=$?
${my_dir}/../../commander/cyber-dojo up

exit $done