#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
exit_non_zero_unless_installed docker
export $(echo_env_vars)

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} {server|client}

    Options:
      server  - build the server image
      client  - build the client image

EOF
}

check_args()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
    'server' | 'client')
      if [ "${CI:-}" == 'true' ]; then
        stderr "In CI workflow, image must be built with Github Action"
        exit_non_zero
      fi
      ;;
    '')
      show_help
      stderr "no argument - must be 'client' or 'server'"
      exit_non_zero
      ;;
    *)
      show_help
      stderr "argument is '${1:-}' - must be 'client' or 'server'"
      exit_non_zero
  esac
}

build_image()
{
  check_args "$@"
  local -r type="${1}"

  if [ "${type}" == 'server' ]; then
    local -r service=dashboard
  else 
    local -r service=client
  fi

  containers_down

  echo "Building server"
  echo "COMMIT_SHA=${COMMIT_SHA}"
  docker compose build "${service}"

  local -r image_name="${CYBER_DOJO_DASHBOARD_IMAGE}:${CYBER_DOJO_DASHBOARD_TAG}"
  local -r sha_in_image=$(docker run --rm --platform linux/amd64 --entrypoint="" "${image_name}" sh -c 'echo -n ${SHA}')
  if [ "${COMMIT_SHA}" != "${sha_in_image}" ]; then
    echo "ERROR: unexpected env-var inside image ${image_name}"
    echo "expected: 'SHA=${COMMIT_SHA}'"
    echo "  actual: 'SHA=${sha_in_image}'"
    exit_non_zero
  fi

  if [ "${type}" == 'server' ]; then
    # Tag image-name for local development where dashboard's name comes from echo_env_vars
    docker tag "${image_name}" "cyberdojo/dashboard:${CYBER_DOJO_DASHBOARD_TAG}"
    # After tagging, so this build is protected by its own tag, and removing an
    # earlier build's tags takes its last tag with them and the image itself
    # goes. check_args rejects both types inside CI, so this script only ever
    # runs locally.
    remove_old_images
    echo
    echo "  echo CYBER_DOJO_DASHBOARD_SHA=${CYBER_DOJO_DASHBOARD_SHA}"
    echo "  echo CYBER_DOJO_DASHBOARD_TAG=${CYBER_DOJO_DASHBOARD_TAG}"
    echo
    echo "${image_name}"
  fi
}

build_image "$@"