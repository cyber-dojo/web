#!/usr/bin/env bash
set -Eeu

exit_non_zero_if_bad_base_image()
{
  # Called in setup job in .github/workflows/main.yml
  base_image="${1}"
  regex=":[a-z0-9]{7}@sha256:[a-z0-9]{64}$"
  if ! [[ ${base_image} =~ $regex ]]; then
    stderr "BASE_IMAGE must have a 7-digit short-sha tag and a full 64-digit digest, Eg"
    stderr " base_image_name  : cyberdojo/web-base"
    stderr " base_image_tag   : 559d354"
    stderr " base_image_digest: ddab9080cd0bbd8e976a18bdd01b37b66e47fe83b0db396e65dc3014bad17fd3"
    exit 42
  fi
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}
