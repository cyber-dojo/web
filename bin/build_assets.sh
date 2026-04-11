#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly BIN_DIR="$(repo_root)/bin"
readonly ASSETS_DIR="$(repo_root)/source/public/assets"
source "${BIN_DIR}/lib.sh"
source "${BIN_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed docker
exit_non_zero_unless_installed curl

docker --log-level=ERROR compose --progress=plain up --detach --no-build --wait --wait-timeout=10 asset_builder

curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.css > "${ASSETS_DIR}/app.css"
curl http://localhost:${CYBER_DOJO_ASSET_BUILDER_PORT}/assets/app.js  > "${ASSETS_DIR}/app.js"
