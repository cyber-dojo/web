#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  echo CYBER_DOJO_WEB_SHA="$(image_sha)"
  echo CYBER_DOJO_WEB_TAG="$(image_tag)"

  echo CYBER_DOJO_NGINX_SHA=2959d4f9a0fee1b8d13ae87e251dbde996b2008f
  echo CYBER_DOJO_NGINX_TAG=2959d4f  
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_WEB_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}
