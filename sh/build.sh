#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly SH_DIR="$(repo_root)/sh"
source "${SH_DIR}/lib.sh"
source "${SH_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

build_tagged_images()
{
  build_web_image
  assert_web_image_has_sha_env_var
  docker tag "${CYBER_DOJO_WEB_IMAGE}:$(image_tag)" "${CYBER_DOJO_WEB_IMAGE}:latest"
  docker tag "${CYBER_DOJO_WEB_IMAGE}:$(image_tag)" "cyberdojo/web:$(image_tag)"
  docker tag "${CYBER_DOJO_WEB_IMAGE}:$(image_tag)" cyberdojo/web:latest
  echo "echo CYBER_DOJO_WEB_SHA=${CYBER_DOJO_WEB_SHA}"
  echo "echo CYBER_DOJO_WEB_TAG=${CYBER_DOJO_WEB_TAG}"
  echo "${CYBER_DOJO_WEB_IMAGE}:$(image_tag)"
  echo "cyberdojo/web:$(image_tag)"
}

build_web_image()
{
  echo
  docker --log-level=ERROR compose \
    --file="$(repo_root)/docker-compose.yml" \
    build
}

assert_web_image_has_sha_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_inside_image)" ]; then
    echo "unexpected env-var inside image $(image_name):latest"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: '$(sha_inside_image)'"
    exit_non_zero
  fi
}

git_commit_sha()
{
  git rev-parse HEAD
}

sha_inside_image()
{
  docker --log-level=ERROR compose run --rm web sh -c 'echo ${SHA}'
}

build_tagged_images