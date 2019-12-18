#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export COMMIT_SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

build_service_image()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
      build \
        "${1}"
}

source ${ROOT_DIR}/sh/cat_env_vars.sh
export $(cat_env_vars)

build_service_image web

readonly IMAGE=cyberdojo/web

images_sha_env_var()
{
  docker run --rm ${IMAGE}:latest sh -c 'env | grep SHA'
}

if [ "SHA=${COMMIT_SHA}" != $(images_sha_env_var) ]; then
  echo "unexpected env-var inside image ${IMAGE}:latest"
  echo "expected: 'SHA=${COMMIT_SHA}'"
  echo "  actual: '$(images_sha_env_var)'"
  exit 42
else
  readonly TAG=${COMMIT_SHA:0:7}
  docker tag ${IMAGE}:latest ${IMAGE}:${TAG}
fi
