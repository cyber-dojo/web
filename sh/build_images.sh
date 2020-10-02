#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  build_web_image
  assert_web_image_has_sha_env_var
}

# - - - - - - - - - - - - - - - - - - - - - - - -
build_web_image()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha)
}

# - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

# - - - - - - - - - - - - - - - - - - - - - - - -
images_sha_env_var()
{
  docker run --rm "$(image_name):latest" sh -c 'echo -n ${SHA}'
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_web_image_has_sha_env_var()
{
  if [ "$(git_commit_sha)" != $(images_sha_env_var) ]; then
    echo "unexpected env-var inside image $(image_name):latest"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: '$(images_sha_env_var)'"
    exit 42
  fi
}
