#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
export SH_DIR="$(repo_root)/sh"

source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/echo_env_vars.sh"
source "${SH_DIR}/exit_zero_if_build_only.sh"
source "${SH_DIR}/exit_non_zero_unless_installed.sh"
source "${SH_DIR}/remove_old_images.sh"
source "${SH_DIR}/run_tests_in_container.sh"

exit_non_zero_unless_installed docker

source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

containers_down
remove_old_images
build_tagged_images
exit_zero_if_build_only "$@"
containers_up
run_tests_in_container "$@"
