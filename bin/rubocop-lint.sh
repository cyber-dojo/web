#!/usr/bin/env bash
set -Eeu

# Runs rubocop and writes its results as junit xml, so CI attests structured
# results rather than a log plus a compliant flag computed in bash.

show_help()
{
  cat <<-EOF
	Usage: bin/rubocop-lint.sh [OPTIONS]

	Lints the ruby source with rubocop and writes junit xml to
	reports/rubocop/junit.xml for CI to attest to Kosli.

	Options:
	  -h    Show this help

	Example:
	  bin/rubocop-lint.sh
	EOF
}

if [ "${1:-}" = '-h' ]; then
  show_help
  exit 0
fi

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -rf "${ROOT_DIR}/reports/rubocop" &> /dev/null || true
mkdir -p "${ROOT_DIR}/reports/rubocop"

# As the invoking user, so junit.xml belongs to whoever ran this rather than to
# the container's user. A root-owned file left in the working tree is unwelcome.
#
# That user has no home dir, so rubocop's cache resolves to /.cache, which it
# cannot create. Caching is off: the cache would die with the container anyway.
DOCKER_CLI_HINTS=false docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  --volume "${ROOT_DIR}/reports/rubocop/:/reports/" \
  --volume "${ROOT_DIR}:/app" \
  cyberdojo/rubocop \
  --raise-cop-error \
  --cache false \
  --format=progress \
  --format=junit \
  --out=/reports/junit.xml
