#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest > /tmp/versioner.env_vars 2>&1
  local -r STATUS=$?
  if [ "${STATUS}" == "0" ]; then
    cat /tmp/versioner.env_vars
    echo CYBER_DOJO_WEB_SHA="$(image_sha)"
    echo CYBER_DOJO_WEB_TAG="$(image_tag)"
  else
    echo "docker run --rm cyberdojo/versioner:latest"
    echo "status == ${STATUS}"
    cat /tmp/versioner.env_vars
    exit 42
  fi
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
