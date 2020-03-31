#!/bin/bash -Eeu

readonly IMAGE=cyberdojo/web
readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export COMMIT_SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

# - - - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    --file "${ROOT_DIR}/docker-compose-choosers.yml" \
    build
}

# - - - - - - - - - - - - - - - - - - - - - - - -
images_sha_env_var()
{
  docker run --rm "${IMAGE}:latest" sh -c 'echo -n ${SHA}'
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
build_images
assert_web_image_has_sha_env_var
