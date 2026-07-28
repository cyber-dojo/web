#!/usr/bin/env bash
set -Eeu

ID="${1}" # eg 3Ef6a2
PORT="${CYBER_DOJO_NGINX_HOST_PORT:-80}"

# Read the kata's committed events via saver's read API through nginx - the same
# URL and port bin/demo.sh opens in the browser. NOT the working-tree
# events.json: saver commits with `git update-ref` and no checkout, so that file
# is frozen at kata-create (see saver/docs/reads-via-git.md).
curl --silent "http://localhost:${PORT}/saver/kata_events?id=${ID}" | jq '.kata_events'
