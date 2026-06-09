#!/usr/bin/env bash
set -Eeu

readonly BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BIN_DIR}/lib.sh"

docker exec -it "$(service_container saver)" bash
