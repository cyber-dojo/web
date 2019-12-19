#!/bin/bash
set -e

readonly IMAGE=cyberdojo/web
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export COMMIT_SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

# - - - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
      build
}

# - - - - - - - - - - - - - - - - - - - - - - - -
images_sha_env_var()
{
  docker run --rm "${IMAGE}:latest" sh -c 'echo ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_web_image_has_sha_env_var()
{
  if [ "${COMMIT_SHA}" != $(images_sha_env_var) ]; then
    echo "unexpected env-var inside image ${IMAGE}:latest"
    echo "expected: 'SHA=${COMMIT_SHA}'"
    echo "  actual: '$(images_sha_env_var)'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_web_image()
{
  local -r TAG=${COMMIT_SHA:0:7}
  docker tag ${IMAGE}:latest ${IMAGE}:${TAG}
}

# - - - - - - - - - - - - - - - - - - - - - - - -
source ${ROOT_DIR}/sh/cat_env_vars.sh
export $(cat_env_vars)
build_images
assert_web_image_has_sha_env_var
tag_web_image
