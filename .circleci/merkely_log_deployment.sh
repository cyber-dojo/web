#!/bin/bash -Eeu

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly MERKELY_CHANGE=merkely/change:latest
readonly MERKELY_OWNER=cyber-dojo
readonly MERKELY_PIPELINE=web

# - - - - - - - - - - - - - - - - - - -
merkely_fingerprint()
{
  echo "docker://${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

	docker run \
    --env MERKELY_COMMAND=log_deployment \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_DESCRIPTION="Deployed to ${environment} in Github Actions pipeline" \
    --env MERKELY_ENVIRONMENT="${environment}" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
export $(curl "${VERSIONER_URL}/app/.env")
export CYBER_DOJO_WEB_TAG="${CIRCLE_SHA1:0:7}"
docker pull ${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}

readonly ENVIRONMENT="${1}"
readonly HOSTNAME="${2}"
merkely_log_deployment "${ENVIRONMENT}" "${HOSTNAME}"
