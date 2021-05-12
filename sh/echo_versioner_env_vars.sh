#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest
  #
  echo CYBER_DOJO_WEB_SHA="$(image_sha)"
  echo CYBER_DOJO_WEB_TAG="$(image_tag)"

  # Forthcoming deployments
  #echo CYBER_DOJO_SAVER_SHA=2ae8e51362c5ad215b86d6065b0f850fae667ea8
  #echo CYBER_DOJO_SAVER_TAG=2ae8e51
  #echo CYBER_DOJO_MODEL_SHA=3fb3f3764cab60078fe5e4577a7a94b786cef308
  #echo CYBER_DOJO_MODEL_TAG=3fb3f37
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
