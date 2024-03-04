#!/usr/bin/env bash
set -Eu

readonly IMAGE_NAME="${1}"  # eg cyberdojo/web:756c728
readonly MAX_WAIT_TIME=5    # max time to wait for IMAGE_NAME to be pushed, in minutes
readonly SLEEP_TIME=10      # wait time between pull checks, in seconds
readonly MAX_ATTEMPTS=$(( MAX_WAIT_TIME * 60 / SLEEP_TIME ))

ATTEMPTS=1

until docker pull "${IMAGE_NAME}"
do
  sleep ${SLEEP_TIME}
  [[ ${ATTEMPTS} -eq ${MAX_ATTEMPTS} ]] && echo "Failed!" && exit 1
  ((ATTEMPTS++))
  echo "Waiting for ${IMAGE_NAME} to be pushed to its registry"
  echo "Attempt # ${ATTEMPTS} / ${MAX_ATTEMPTS}"
done
echo "Success: Artifact ${IMAGE_NAME} has been pushed to its registry"
exit 0
