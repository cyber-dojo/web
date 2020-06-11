
# curled by https://github.com/dpolivaev/cyber-dojo-k8s-install/blob/master/install.sh

helm_upgrade()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r helm_repo="${3}"
  local -r image="${4}"
  local -r tag="${5}"
  local -r port="${6}"
  local -r general_values="${7}"
  if [ -z "${8:-}" ]; then
    local -r specific_values=""
  else
    local -r specific_values="--values ${8}"
  fi

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --set containers[0].livenessProbe.port=${port} \
    --set containers[0].readinessProbe.port=${port} \
    --set-string service.annotations."prometheus\.io/port"=${port} \
    --values ${general_values} \
    ${specific_values} \
    ${namespace}-${repo} \
    ${helm_repo}
}
