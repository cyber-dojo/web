#!/usr/bin/env bash
set -Eeu

remove_old_images()
{
  echo Removing old images
  # grep exits non-zero when no web image is present, eg on a machine whose
  # images have just been cleared, so an empty list must not end the build.
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep 'web:' || true)
  remove_all_but_current "${dil}" "${CYBER_DOJO_WEB_IMAGE}"
  remove_all_but_current "${dil}" cyberdojo/web
}

# Keeps this commit's tag, which names the build just made. Every older tag
# goes, and an earlier build whose last tag was one of those goes with it.
remove_all_but_current()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in $(echo "${docker_image_ls}" | grep "${name}:" || true)
  do
    if [ "${image_name}" != "${name}:$(image_tag)" ]; then
      # Removing by name:tag untags, so this succeeds even while a container
      # references the image, leaving it dangling until that container goes.
      # The guard is for a genuine daemon error: report it rather than abort the
      # whole build under set -Eeu.
      docker image rm --force "${image_name}" || echo "  ${image_name} not removed"
    fi
  done
}
