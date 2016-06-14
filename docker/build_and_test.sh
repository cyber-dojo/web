#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

cd ${my_dir}/web
./build-image.sh
cd ${my_dir}

./cyber-dojo down
./cyber-dojo up
cid=`docker ps --all --quiet --filter "name=cdf-web"`
docker exec ${cid} sh -c "cd test && ./run.sh"
done=$?
exit $done