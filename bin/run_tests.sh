#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
export BIN_DIR="$(repo_root)/bin"

source "${BIN_DIR}/containers_down.sh"
source "${BIN_DIR}/containers_up.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/run_tests_in_container.sh"
source "${BIN_DIR}/lib.sh"
source "${BIN_DIR}/echo_env_vars.sh"

exit_non_zero_unless_installed docker
export $(echo_env_vars)
containers_down
containers_up
run_tests_in_container "$@"
