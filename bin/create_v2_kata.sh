#!/usr/bin/env bash
set -Eeu

# Call this after running `make demo`

create_v2_kata()
{
  local count="${1:-1}"
  docker exec \
    --env CYBER_DOJO_SAVER_CLASS=SaverService \
    test_web \
    bash -c "ruby /web/source/script/create_v2_kata.rb ${count}"
}
