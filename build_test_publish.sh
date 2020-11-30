#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/on_ci_publish_tagged_images.sh"
source "${SH_DIR}/setup_dependent_images.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/run_tests_in_container.sh"

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

exit_non_zero_unless_installed docker
exit_non_zero_unless_installed docker-compose
containers_down
remove_old_images
build_tagged_images
exit_zero_if_build_only
#setup_dependent_images
containers_up
run_tests_in_container "$@"
on_ci_publish_tagged_images
