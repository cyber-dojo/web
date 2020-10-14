#!/bin/bash -Eeu

readonly MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly NAMESPACE="${1}" # beta|prod
readonly K8S_URL=https://raw.githubusercontent.com/cyber-dojo/k8s-install/master
readonly VERSIONER_URL=https://raw.githubusercontent.com/cyber-dojo/versioner/master
source <(curl "${K8S_URL}/sh/deployment_functions.sh")
export $(curl "${VERSIONER_URL}/app/.env")
readonly CYBER_DOJO_WEB_TAG="${CIRCLE_SHA1:0:7}"
readonly YAML_VALUES_FILE="${MY_DIR}/k8s-general-values.yml"

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
modified_helm_upgrade_probe_yes_prometheus_no()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r image="${3}"
  local -r tag="${4}"
  local -r port="${5}"
  local -r general_values="${6}"
  if [ -z "${7:-}" ]; then
    local -r specific_values=""
  else
    local -r specific_values="--values ${7}"
  fi

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --set containers[0].livenessProbe.httpGet.port=${port} \
    --set containers[0].readinessProbe.httpGet.port=${port} \
    --values ${general_values} \
    ${specific_values} \
    ${namespace}-${repo} \
    ${HELM_CHART_REPO} \
    --version ${HELM_CHART_VERSION}
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gcloud_init
helm_init

cat "${MY_DIR}/env-var-values.yml" >> "${YAML_VALUES_FILE}"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cat "${YAML_VALUES_FILE}"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

modified_helm_upgrade_probe_yes_prometheus_no \
   "${NAMESPACE}" \
   "web" \
   "${CYBER_DOJO_WEB_IMAGE}" \
   "${CYBER_DOJO_WEB_TAG}" \
   "${CYBER_DOJO_WEB_PORT}" \
   "${YAML_VALUES_FILE}"
