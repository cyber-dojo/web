#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -rf "${ROOT_DIR}/reports/rubocop" &> /dev/null || true
mkdir -p "${ROOT_DIR}/reports/rubocop"

# As the invoking user, so junit.xml belongs to whoever ran this rather than to
# the container's user. A file owned by someone else breaks kosli attest, which
# copies evidence with PreserveOwner and cannot chown to another uid, and is
# unwelcome in a working tree regardless.
# That user has no entry in the container's /etc/passwd, so HOME defaults to /
# and rubocop reports, once per inspected file, that it cannot create /.cache.
# Naming a writable HOME lets it cache and say nothing.
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --volume "${ROOT_DIR}/reports/rubocop/:/reports/" \
  --volume "${ROOT_DIR}:/app" \
  cyberdojo/rubocop \
  --raise-cop-error \
  --format=progress \
  --format=junit \
  --out=/reports/junit.xml
