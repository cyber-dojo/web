#!/usr/bin/env bash
set -Eeu

# Call this after running `make demo`

docker exec \
  --env CYBER_DOJO_SAVER_CLASS=SaverService \
  -it \
  test_web \
  bash -c 'ruby /cyber-dojo/script/create_v2_kata.rb'