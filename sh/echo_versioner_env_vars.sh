#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  echo CYBER_DOJO_WEB_SHA="$(image_sha)"
  echo CYBER_DOJO_WEB_TAG="$(image_tag)"

  echo CYBER_DOJO_NGINX_SHA=1216c6b07e2c4524bf8f26a45688ac5bbe0af5ee
  echo CYBER_DOJO_NGINX_TAG=1216c6b

  echo CYBER_DOJO_MODEL_SHA=ca5805255f5b57a68a17d0070fc2ab4cd4331f94
  echo CYBER_DOJO_MODEL_TAG=ca58052
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
