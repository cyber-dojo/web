#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
BIN_DIR="$(repo_root)/creator/bin"
source "${BIN_DIR}/containers_down.sh"
source "${BIN_DIR}/containers_up_healthy_and_clean.sh"
source "${BIN_DIR}/copy_in_saver_test_data.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/exit_zero_if_build_only.sh"
source "${BIN_DIR}/exit_zero_if_show_help.sh"
source "${BIN_DIR}/lib.sh"
source "${BIN_DIR}/test_in_containers.sh"

# shellcheck disable=SC2046
export $(echo_env_vars)

run_tests_with_coverage()
{
  set +e
  exit_status=0

  exit_zero_if_show_help "$@"
  exit_non_zero_unless_installed docker jq

  # Clear any containers a previous (failed) run left up for inspection, so
  # this run starts from a clean slate.
  containers_down

  # Build with the git commit-sha baked in (Dockerfile ENV SHA, via the
  # COMMIT_SHA build-arg). Plain 'docker compose up' builds without it, leaving
  # /sha empty (see RouteShaTest). Mirrors bin/demo.sh.
  docker compose build --build-arg COMMIT_SHA="$(git_commit_sha)" creator

  server_up_healthy_and_clean
  client_up_healthy_and_clean "$@"
  copy_in_saver_test_data
  test_in_containers "$@" || exit_status=$?
  if [ "${exit_status}" -eq 0 ]; then
    containers_down
  else
    # Leave the containers (and their volumes) up so their logs survive for
    # diagnosing the failure - tearing them down here would discard exactly
    # the evidence you need. The next test run clears them at its start.
    echo
    echo "Tests failed - leaving containers up so you can inspect them:"
    echo "  docker compose logs            # all services"
    echo "  docker compose logs creator    # just the server"
    echo "  docker compose down --remove-orphans --volumes   # when done"
  fi
  write_test_evidence_json "$@"
  set -e

  return ${exit_status}
}

# Allow this script to be run directly, eg
#   bin/run_tests_with_coverage.sh server
# as well as sourced-then-called (how the Makefile uses it). When the script is
# executed, BASH_SOURCE[0] equals $0; when it is sourced, they differ - so this
# only auto-runs on direct execution and leaves the sourced usage untouched.
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  run_tests_with_coverage "$@"
fi
