#!/usr/bin/env bash
set -Eeu

# Runs rubocop and writes its results as junit xml, so CI attests structured
# results rather than a log plus a compliant flag computed in bash.

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -rf "${ROOT_DIR}/reports/rubocop" &> /dev/null || true
mkdir -p "${ROOT_DIR}/reports/rubocop"

# As the invoking user, so junit.xml belongs to whoever ran this rather than to
# the container's user. A file owned by someone else breaks kosli attest, which
# copies evidence with PreserveOwner and cannot chown to another uid, and is
# unwelcome in a working tree regardless.
DOCKER_CLI_HINTS=false docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  --volume "${ROOT_DIR}/reports/rubocop/:/reports/" \
  --volume "${ROOT_DIR}:/app" \
  cyberdojo/rubocop \
  --raise-cop-error \
  --format=progress \
  --format=junit \
  --out=/reports/junit.xml
