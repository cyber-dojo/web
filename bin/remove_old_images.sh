#!/usr/bin/env bash
set -Eeu

remove_old_images()
{
  local -r docker_image_ls=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  local -r name="${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}"
  for image_name in $(echo "${docker_image_ls}" | grep "web:")
  do
    if [ "${image_name}" != "${name}" ]; then
      docker image rm --force "${image_name}"
    fi
  done
}
