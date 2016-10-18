#!/bin/sh
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

echo 'Building image'
${my_dir}/../build-image.sh

echo 'Bringing down server'
${my_dir}/../../commander/cyber-dojo down

echo 'Bringing up server'
${my_dir}/../../commander/cyber-dojo up

echo 'Shelling into web container and running tests'
cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"
done=$?

root=/usr/src/cyber-dojo
modules=( app_controllers app_helpers app_lib app_models lib )
echo
echo "Copying coverage stats out of container"
for module in ${modules[*]}
do
  docker cp ${cid}:${root}/test/${module}/coverage/ ${my_dir}/../coverage/${module}
done

exit $done