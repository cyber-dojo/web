#!/usr/bin/env bash
set -Eeu

readonly BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${BIN_DIR}/lib.sh"

ID="${1}"      # eg 3Ef6a2
P1="${ID:0:2}" # eg 3E
P2="${ID:2:2}" # eg f6
P3="${ID:4:2}" # eg a2

docker exec "$(service_container saver)" bash -c "jq . /cyber-dojo/katas/${P1}/${P2}/${P3}/manifest.json"
