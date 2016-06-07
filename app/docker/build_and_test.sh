#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
now_dir=`pwd`

cd ${my_dir}/web
./build-image.sh
cd ${my_dir}

./cyber-dojo down
./cyber-dojo up
cid=`docker ps -aqf "name=cdf-web"`
docker exec ${cid} sh -c "cd test && ./run.sh"
done=$?
echo "done=${done}"
cd ${now_dir}
exit $done