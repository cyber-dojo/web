#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/build_images.sh"
source "${SH_DIR}/tag_image.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/setup_dependent_images.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/run_tests_in_container.sh"
source "${SH_DIR}/on_ci_publish_tagged_images.sh"
source "${SH_DIR}/versioner_env_vars.sh"

export $(versioner_env_vars)

containers_down
build_images
tag_image
exit_zero_if_build_only
setup_dependent_images
containers_up
run_tests_in_container "$@"
on_ci_publish_tagged_images
