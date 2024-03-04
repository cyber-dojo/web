#!/usr/bin/env bash
set -Eu

IMAGE_NAME="${1}"        # eg cyberdojo/web:6d650d5
KOSLI_HOST="${2}"        # eg https://app.kosli.com
KOSLI_API_TOKEN="${3}"   # eg 7654y432er7132rwaefdgzfvdc (fake)
KOSLI_ORG="${4}"         # eg cyber-dojo
KOSLI_ENVIRONMENT="${5}" # eg aws-prod

image_deployed()
{
    local -r snapshot_json_filename=snapshot.json

    # Use Kosli CLI to get info on what artifacts are currently running
    # (docs/snapshot.json contains an example json file)
    echo "Getting snapshot from ${KOSLI_ENVIRONMENT} on ${KOSLI_HOST}"

    kosli get snapshot "${KOSLI_ENVIRONMENT}" \
      --host="${KOSLI_HOST}" \
      --api-token="${KOSLI_API_TOKEN}" \
      --org="${KOSLI_ORG}" \
      --output=json \
        > "${snapshot_json_filename}"

    # Process info, one artifact at a time
    local -r artifacts_length=$(jq '.artifacts | length' ${snapshot_json_filename})
    for i in $(seq 0 $(( artifacts_length - 1 )));
    do
        annotation_type=$(jq -r ".artifacts[$i].annotation.type" ${snapshot_json_filename})
        if [ "${annotation_type}" != "exited" ]; then
          name=$(jq -r ".artifacts[$i].name" ${snapshot_json_filename})
          fingerprint=$(jq -r ".artifacts[$i].fingerprint" ${snapshot_json_filename})
          echo "Looking at Artifact ${name}"
          if [ "${fingerprint}" == "${FINGERPRINT}" ]; then
            echo "MATCHED: ${fingerprint} == ${FINGERPRINT}"
            return 0 # true
          else
            echo "NO-MATCH ${fingerprint} != ${FINGERPRINT}"
          fi
       fi
    done
    return 1 # false
}

image_not_deployed()
{
    local -r snapshot_json_filename=snapshot.json
    echo "Failed!"
    cat "${snapshot_json_filename}"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

docker pull "${IMAGE_NAME}"
FINGERPRINT=$(kosli fingerprint "${IMAGE_NAME}" --artifact-type=docker)

MAX_WAIT_TIME=15 # max time to wait for image to be deployed, in minutes
SLEEP_TIME=20    # wait time between deployment checks, in seconds
MAX_ATTEMPTS=$(( MAX_WAIT_TIME * 60 / SLEEP_TIME ))
ATTEMPTS=1

until image_deployed
do
  sleep 10
  [[ ${ATTEMPTS} -eq ${MAX_ATTEMPTS} ]] && image_not_deployed && exit 42
  ((ATTEMPTS++))
  echo "Waiting for deployment of Artifact ${IMAGE_NAME} to Environment ${KOSLI_ENVIRONMENT}"
  echo "Attempt # ${ATTEMPTS} / ${MAX_ATTEMPTS}"
done
echo "Success: Artifact ${IMAGE_NAME} is running in Environment ${KOSLI_ENVIRONMENT}"
exit 0
