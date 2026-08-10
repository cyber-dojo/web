#!/usr/bin/env bash
set -Eeu

show_help()
{
  cat <<'EOF'
Usage: bin/run_client_tests.sh [OPTIONS] [TEST-ID]...

Runs ONLY the browser (Capybara + Selenium) tests, for a fast inner loop
when working on the browser-driven JavaScript. Unlike bin/run_tests.sh it does
not tear existing containers down, does not pull the runner test image, and does
not run the unit suite.

The web image loads its JavaScript from the built image, so your current code is
only exercised after the image is rebuilt. Run 'make image' first after changing
any JavaScript.

Naming one or more test-ids runs only the tests whose id contains one of
them; naming none runs the whole browser suite.

Options:
  -h    Show this help

Example:
  bin/run_client_tests.sh
  bin/run_client_tests.sh fK3nQ7
EOF
}

while getopts 'h' option; do
  case "${option}" in
    h) show_help; exit 0 ;;
    *) show_help; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

repo_root() { git rev-parse --show-toplevel; }
export BIN_DIR="$(repo_root)/bin"

source "${BIN_DIR}/containers_up.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/run_tests_in_container.sh"
source "${BIN_DIR}/lib.sh"

exit_non_zero_unless_installed docker
export $(echo_env_vars)
# Before containers_up, for the reason pull_runner_test_image explains. The
# browser drives the served app, which runs [test] through the real runner.
pull_runner_test_image
client_containers_up
copy_saver_test_data
run_client_tests_in_container "$@"
