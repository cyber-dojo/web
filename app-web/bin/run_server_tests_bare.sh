#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
export BIN_DIR="$(repo_root)/app-web/bin"

source "${BIN_DIR}/containers_down.sh"
source "${BIN_DIR}/containers_up.sh"
source "${BIN_DIR}/echo_env_vars.sh"
source "${BIN_DIR}/run_tests_in_container.sh"
source "${BIN_DIR}/lib.sh"

# The server tests, run without the deployed image: in the bare image, the
# Dockerfile's base stage (Ruby, its gems and the OS packages, with no source
# code), as docker-compose.bare.yml lays it over docker-compose.yml. The
# compiled assets come from the Dockerfile's web-assets-files stage. The bare
# image's packages are saved to app-web/reports/bare_image_packages.txt (see
# bin/image_packages.sh).

readonly LOCAL_BARE_IMAGE=web-bare-image:local
readonly REPORTS_DIR="$(repo_root)/app-web/reports"

show_help()
{
    local -r MY_NAME=$(basename "${BASH_SOURCE[0]}")
    cat <<- EOF

    Use: ${MY_NAME} [ID...]

    Runs the web server tests in the bare image: the one named by
    CYBER_DOJO_WEB_BARE_IMAGE, or else one built here with
    docker build --target base (${LOCAL_BARE_IMAGE}). Writes app-web/reports,
    as run_server_tests.sh does, and app-web/reports/bare_image_packages.txt.

    Options:
       -h     Show this help
       ID...  Only run tests whose id starts with one of these prefixes

    Example:
       ${MY_NAME}
       CYBER_DOJO_WEB_BARE_IMAGE=web-bare-image:ab12cd3 ${MY_NAME} F1B7C

EOF
}

# The bare image: the one given, or one built from the Dockerfile's base stage.
bare_image()
{
  if [ -n "${CYBER_DOJO_WEB_BARE_IMAGE:-}" ]; then
    echo "${CYBER_DOJO_WEB_BARE_IMAGE}"
  else
    docker build --target base --tag "${LOCAL_BARE_IMAGE}" "$(repo_root)" >&2
    echo "${LOCAL_BARE_IMAGE}"
  fi
}

# The directory holding app.css and app.js, compiled as the deployed image's are.
compiled_assets_dir()
{
  local -r dir="${REPORTS_DIR}/assets"
  docker build --target web-assets-files --output "type=local,dest=${dir}" "$(repo_root)" >&2
  echo "${dir}"
}

# The packages of the web container the tests run in.
save_bare_image_packages()
{
  "$(repo_root)/bin/image_packages.sh" container "$(service_container web)" \
      > "${REPORTS_DIR}/bare_image_packages.txt"
  echo "web server test bare image packages are at:"
  echo "${REPORTS_DIR}/bare_image_packages.txt"
  echo
}

main()
{
  case "${1:-}" in
    '-h' | '--help')
      show_help
      exit 0
      ;;
  esac
  exit_non_zero_unless_installed docker
  export $(echo_env_vars)
  # No earlier run's reports may stand in for this run's.
  rm -rf "${REPORTS_DIR}"
  # Short flag: macOS's mkdir has no --parents.
  mkdir -p "${REPORTS_DIR}"
  CYBER_DOJO_WEB_BARE_IMAGE="$(bare_image)"
  export CYBER_DOJO_WEB_BARE_IMAGE
  CYBER_DOJO_WEB_ASSETS_DIR="$(compiled_assets_dir)"
  export CYBER_DOJO_WEB_ASSETS_DIR

  containers_down
  pull_runner_test_image
  server_containers_up --file "$(repo_root)/docker-compose.bare.yml"
  save_bare_image_packages
  run_server_tests_in_container "$@"
}

main "$@"
