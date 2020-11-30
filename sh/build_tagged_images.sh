#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  build_web_image
  assert_web_image_has_sha_env_var
  docker tag ${CYBER_DOJO_WEB_IMAGE}:$(image_tag) ${CYBER_DOJO_WEB_IMAGE}:latest
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

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_web_image_has_sha_env_var()
{
  if [ "$(git_commit_sha)" != $(sha_inside_image) ]; then
    echo "unexpected env-var inside image $(image_name):latest"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: '$(sha_inside_image)'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  cd "${ROOT_DIR}" && git rev-parse HEAD
}

#- - - - - - - - - - - - - - - - - - - - - - - -
sha_inside_image()
{
  docker run --rm "$(image_name):$(image_tag)" sh -c 'echo ${SHA}'
}
