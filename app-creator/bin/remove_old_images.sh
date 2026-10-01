
remove_old_images()
{
  echo Removing old images
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_current "${dil}" "${CYBER_DOJO_CREATOR_IMAGE}"
}

# Keeps this commit's tag, which names the build just made. Every older tag
# goes, and an earlier build whose last tag was one of those goes with it.
remove_all_but_current()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  # grep exits non-zero when the machine holds no creator image, eg one whose
  # images have just been cleared, so an empty list must not end the build.
  local tagged_name
  for tagged_name in $(echo "${docker_image_ls}" | grep "^${name}:" || true)
  do
    if [ "${tagged_name}" != "${name}:$(image_tag)" ]; then
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
}
