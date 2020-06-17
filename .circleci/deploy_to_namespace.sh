#!/bin/bash -Eeu

source <(curl https://raw.githubusercontent.com/cyber-dojo/k8s-install/master/sh/deployment_functions.sh)

# misc env-vars are in ci context

echo ${GCP_K8S_CREDENTIALS} > /gcp/gcp-credentials.json

gcloud auth activate-service-account \
  "${SERVICE_ACCOUNT}" \
  --key-file=/gcp/gcp-credentials.json

gcloud container clusters get-credentials \
  "${CLUSTER}" \
  --zone "${ZONE}" \
  --project "${PROJECT}"

helm init --client-only

helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Normally I export the cyberdojo env-vars using the command
# $ docker run --rm cyberdojo/versioner:latest
# This won't work on the .circleci deployment step since it is
# run inside the cyberdojo/gcloud-kubectl-helm image which does
# not have docker. So doing it directly from versioner's git repo
export $(curl https://raw.githubusercontent.com/cyber-dojo/versioner/master/app/.env)

readonly NAMESPACE="${1}" # beta|prod
readonly CYBER_DOJO_WEB_TAG="${CIRCLE_SHA1:0:7}"

K8S_SET_PROMETHEUS=false \
K8S_SET_PROBES=false \
helm_upgrade \
   "${NAMESPACE}" \
   "web" \
   "${CYBER_DOJO_WEB_IMAGE}" \
   "${CYBER_DOJO_WEB_TAG}" \
   "${CYBER_DOJO_WEB_PORT}" \
   ".circleci/k8s-general-values.yml"
