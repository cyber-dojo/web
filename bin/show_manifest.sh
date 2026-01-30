#!/usr/bin/env bash
set -Eeu

ID="${1}"      # eg 3Ef6a2
P1="${ID:0:2}" # eg 3E
P2="${ID:2:2}" # eg f6
P3="${ID:4:2}" # eg a2

docker exec test_web_saver bash -c "jq . /cyber-dojo/katas/${P1}/${P2}/${P3}/manifest.json"
