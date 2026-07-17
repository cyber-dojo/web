#!/usr/bin/env bash
set -Eeu

show_help()
{
  cat <<'EOF'
Usage: bin/run_browser_tests.sh [OPTIONS]

Runs ONLY the app_browser (Capybara + Selenium) tests, for a fast inner loop
when working on the browser-driven JavaScript. Unlike bin/run_tests.sh it does
not tear existing containers down, does not pull the runner test image, and does
not run the unit suite.

The web image loads its JavaScript from the built image, so your current code is
only exercised after the image is rebuilt. The Makefile target 'test_browser'
rebuilds it first (via 'make image') before calling this script.

Options:
  -h    Show this help

Example:
  bin/run_browser_tests.sh
EOF
}

while getopts 'h' option; do
  case "${option}" in
    h) show_help; exit 0 ;;
    *) show_help; exit 1 ;;
  esac
done

# Silence the docker CLI "What's next:" hint banner for the whole run.
export DOCKER_CLI_HINTS=false

repo_root() { git rev-parse --show-toplevel; }
export BIN_DIR="$(repo_root)/bin"

source "${BIN_DIR}/containers_up.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/run_tests_in_container.sh"
source "${BIN_DIR}/lib.sh"

exit_non_zero_unless_installed docker
export $(echo_env_vars)
containers_up
copy_saver_test_data
run_browser_tests_in_container
