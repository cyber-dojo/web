#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
source "${BIN_DIR}/lib.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/remove_old_images.sh"
export $(echo_env_vars)

exit_non_zero_if_on_ci()
{
  # CI builds the image exactly once, in the build-image job, whose digest
  # becomes the Kosli fingerprint. Every later job (run-server-tests,
  # run-client-tests, snyk-container-scan) loads that same tar by digest via
  # cyber-dojo/download-artifact, and sdlc-control-gate asserts on that
  # fingerprint before deploy-to-beta ships it.
  #
  # A build here would replace the artifact under test with a different image.
  # This build is not set up to be reproducible (no pinned SOURCE_DATE_EPOCH or
  # buildkit rewrite-timestamp), so rebuilding identical source still yields a
  # new digest, and that digest cannot be recomputed afterwards. The test and
  # scan evidence would then vouch for an artifact nobody tested, which is the
  # one direction that must never happen. Hence `make test_server` does not
  # depend on the image target, and building on CI is an error rather than a
  # slow path.
  if on_ci; then
    stderr "Inside CI workflow you must use secure-docker-build.yml reusable workflow"
    exit_non_zero
  fi
}

build_tagged_images()
{
  exit_non_zero_if_on_ci
  build_web_image
  assert_web_image_has_sha_env_var
  # Tag image-name for local development, where sibling repos name the web
  # image with the dockerhub name their env-vars carry rather than the ECR one.
  docker tag "${CYBER_DOJO_WEB_IMAGE}:$(image_tag)" "cyberdojo/web:$(image_tag)"
  # After tagging, so this build is protected by its own tag, and removing an
  # earlier build's tags takes its last tag with them and the image itself goes.
  remove_old_images
  echo
  echo "  echo CYBER_DOJO_WEB_SHA=${CYBER_DOJO_WEB_SHA}"
  echo "  echo CYBER_DOJO_WEB_TAG=${CYBER_DOJO_WEB_TAG}"
  echo
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
    echo "unexpected env-var inside image $(image_name):$(image_tag)"
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