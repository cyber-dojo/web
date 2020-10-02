#!/bin/bash -Eeu

readonly lsp_service_name=languages-start-points
readonly lsp_container_name=test_web_languages_start_points

source "${ROOT_DIR}/sh/wait_until_ready.sh"

# - - - - - - - - - - - - - - - - - - - - - - - -
setup_dependent_images()
{
  start_lsp
  wait_until_ready "${lsp_container_name}" "$(lsp_port)"
  pull_dependent_images
}

# - - - - - - - - - - - - - - - - - - - - - - - -
lsp_port()
{
  echo "${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
json_data()
{
  local -r display_name="${1}"
  cat <<- EOF
  { "name":"${display_name}" }
EOF
}

# - - - - - - - - - - - - - - - - - - - - - - - -
pull_dependent_images()
{
  echo
  echo Images used in web tests must be pulled onto the node before runner is started.

  local -r display_names="$(
    docker run \
      --entrypoint='' \
      --rm \
      --volume ${ROOT_DIR}/test:/test/:ro \
        ${CYBER_DOJO_RUNNER_IMAGE} \
          ruby /test/dependent_display_names.rb)"

  echo "${display_names}" \
    | while read display_name
      do
        local json="$(json_data "${display_name}")"
        local manifest="$(curl \
          --data "${json}" \
          --silent \
          -X GET \
          "http://$(ip_address):$(lsp_port)/manifest")"

        local image_name=$(echo "${manifest}" | jq --raw-output '.manifest.image_name')

        echo "${image_name}"
        docker pull "${image_name}"
      done
}

# - - - - - - - - - - - - - - - - - - - - - - - -
start_lsp()
{
  echo
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    up \
    -d \
    --force-recreate \
    "${lsp_service_name}"
}
