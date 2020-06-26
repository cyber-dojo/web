#!/bin/bash -Eeu

readonly IMAGE=${CYBER_DOJO_WEB_IMAGE}
readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export COMMIT_SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

# - - - - - - - - - - - - - - - - - - - - - - - -
build_web_image()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg BUILD_ENV=copy
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
build_web_image
assert_web_image_has_sha_env_var
