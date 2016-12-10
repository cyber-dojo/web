#!/bin/bash
set -e

my_dir="$( cd "$( dirname "${0}" )" && pwd )"

cid=`docker ps --all --quiet --filter "name=cyber-dojo-web"`
docker exec ${cid} sh -c "cd test && ./run.sh ${*}"

# copy coverage stats out of container
modules=( app_helpers app_lib app_models lib app_controllers )
for module in ${modules[*]}
do
  # to copy the *contents* of a dir docker cp requires a trailing dot
  src=${cid}:/usr/src/cyber-dojo/test/${module}/coverage/.
  dst=${my_dir}/coverage/${module}
  docker cp ${src} ${dst}
done
