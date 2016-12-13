#!/bin/bash
set -e

cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"

# copy coverage stats out of container
my_dir="$( cd "$( dirname "${0}" )" && pwd )"
mkdir -p ${my_dir}/coverage

modules=( app_helpers app_lib app_models lib app_controllers )
for module in ${modules[*]}
do
  # copying the *contents* of a dir [docker cp] requires a trailing dot
  src=${cid}:/tmp/cyber-dojo/${module}/coverage/.
  dst=${my_dir}/coverage/${module}
  docker cp ${src} ${dst}
done
