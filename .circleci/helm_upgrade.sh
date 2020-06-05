
# curled by https://github.com/dpolivaev/cyber-dojo-k8s-install/blob/master/install.sh

helm_upgrade()
{
  local -r namespace="${1}"
  local -r image="${2}"
  local -r tag="${3}"
  local -r port="${4}"
  local -r general_values="${5}"
  local -r specific_values="${6}"
  local -r repo="${7}"
  local -r helm_repo="${8}"

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --values ${general_values} \
    --values ${specific_values} \
    ${namespace}-${repo} \
    ${helm_repo}
}
