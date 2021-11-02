#!/bin/bash -Eeu

# ROOT_DIR must be set

readonly MERKELY_CHANGE=merkely/change:latest
readonly MERKELY_OWNER=cyber-dojo
readonly MERKELY_PIPELINE=web

# - - - - - - - - - - - - - - - - - - -
merkely_fingerprint()
{
  echo "docker://${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
merkely_declare_pipeline()
{
  local -r hostname="${1}"

	docker run \
		--env MERKELY_COMMAND=declare_pipeline \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
		--env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
		--rm \
		--volume ${ROOT_DIR}/Merkelypipe.json:/data/Merkelypipe.json \
		  ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_artifact()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_artifact \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_ARTIFACT_GIT_COMMIT=${CYBER_DOJO_WEB_SHA} \
    --env MERKELY_ARTIFACT_GIT_URL=https://github.com/${MERKELY_OWNER}/${MERKELY_PIPELINE}/commit/${CYBER_DOJO_WEB_SHA} \
    --env MERKELY_CI_BUILD_NUMBER=${CIRCLE_BUILD_NUM} \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
merkely_log_evidence()
{
  local -r hostname="${1}"

	docker run \
    --env MERKELY_COMMAND=log_evidence \
    --env MERKELY_OWNER=${MERKELY_OWNER} \
    --env MERKELY_PIPELINE=${MERKELY_PIPELINE} \
    --env MERKELY_FINGERPRINT=$(merkely_fingerprint) \
    --env MERKELY_EVIDENCE_TYPE=branch-coverage \
    --env MERKELY_IS_COMPLIANT=TRUE \
    --env MERKELY_DESCRIPTION="server & client branch-coverage reports" \
    --env MERKELY_USER_DATA="$(evidence_json_path)" \
    --env MERKELY_CI_BUILD_URL=${CIRCLE_BUILD_URL} \
    --env MERKELY_API_TOKEN=${MERKELY_API_TOKEN} \
    --env MERKELY_HOST="${hostname}" \
    --rm \
    --volume "$(evidence_json_path):$(evidence_json_path)" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
      ${MERKELY_CHANGE}
}

# - - - - - - - - - - - - - - - - - - -
write_evidence_json()
{
  echo '{ "server": ' > "$(evidence_json_path)"
  cat "${ROOT_DIR}/test/server/reports/coverage.json" >> "$(evidence_json_path)"
  echo ', "client": ' >> "$(evidence_json_path)"
  cat "${ROOT_DIR}/test/client/reports/coverage.json" >> "$(evidence_json_path)"
  echo '}' >> "$(evidence_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
evidence_json_path()
{
  echo "${ROOT_DIR}/test/evidence.json"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI:-}" ]
}

# - - - - - - - - - - - - - - - - - - -
on_ci_merkely_declare_pipeline()
{
  if ! on_ci ; then
    return
  fi
  merkely_declare_pipeline https://staging.app.merkely.com
  merkely_declare_pipeline https://app.merkely.com
}

# - - - - - - - - - - - - - - - - - - -
on_ci_merkely_log_artifact()
{
  if ! on_ci ; then
    return
  fi
  merkely_log_artifact https://staging.app.merkely.com
  merkely_log_artifact https://app.merkely.com
}

# - - - - - - - - - - - - - - - - - - -
on_ci_merkely_log_evidence()
{
  if ! on_ci ; then
    return
  fi
  write_evidence_json
  merkely_log_evidence https://staging.app.merkely.com
  merkely_log_evidence https://app.merkely.com
}



