#!/usr/bin/env bash
set -Eeu

# Runs rubocop and writes its results as junit xml, so CI attests structured
# results rather than a log plus a compliant flag computed in bash.

show_help()
{
  cat <<-EOF
	Usage: web/bin/rubocop-lint.sh [OPTIONS]

	Lints the ruby source with rubocop and writes junit xml to
	web/reports/rubocop/junit.xml for CI to attest to Kosli.

	Options:
	  -h    Show this help

	Example:
	  web/bin/rubocop-lint.sh
	EOF
}

if [ "${1:-}" = '-h' ]; then
  show_help
  exit 0
fi

# The app dir holds .rubocop.yml beside the code it lints, so rubocop reads
# the config's relative paths against the right tree.
readonly WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPORTS_DIR="${WEB_DIR}/reports"
# For the shared docker settings.
source "${WEB_DIR}/bin/lib.sh"

rm -rf "${REPORTS_DIR}/rubocop" &> /dev/null || true
mkdir -p "${REPORTS_DIR}/rubocop"

# As the invoking user, so junit.xml belongs to whoever ran this rather than to
# the container's user. A root-owned file left in the working tree is unwelcome.
#
# That user has no home dir, so rubocop's cache resolves to /.cache, which it
# cannot create. Caching is off: the cache would die with the container anyway.
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  --volume "${REPORTS_DIR}/rubocop/:/reports/" \
  --volume "${WEB_DIR}:/app" \
  cyberdojo/rubocop \
  --raise-cop-error \
  --cache false \
  --format=progress \
  --format=junit \
  --out=/reports/junit.xml
