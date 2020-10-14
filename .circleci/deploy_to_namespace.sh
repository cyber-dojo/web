#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly NAMESPACE="${1}" # beta|prod
readonly K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
readonly VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
source <(curl "${K8S_URL}/sh/deployment_functions.sh")
export $(curl "${VERSIONER_URL}/app/.env")
readonly CYBER_DOJO_WEB_TAG="${CIRCLE_SHA1:0:7}"
readonly YAML_VALUES_FILE="${MY_DIR}/k8s-general-values.yml"

gcloud_init
helm_init

cat "${MY_DIR}/env-var-values.yml" >> "${YAML_VALUES_FILE}"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cat "${YAML_VALUES_FILE}"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

helm_upgrade_probe_no_prometheus_no \
   "${NAMESPACE}" \
   "web" \
   "${CYBER_DOJO_WEB_IMAGE}" \
   "${CYBER_DOJO_WEB_TAG}" \
   "${CYBER_DOJO_WEB_PORT}" \
   "${YAML_VALUES_FILE}"
