#!/usr/bin/env bash
set -Eeu

# Runs rubocop over one app and writes its results as junit xml, so CI attests
# structured results rather than a log plus a compliant flag computed in bash.
# Every app's <app>_rubocop_lint make target calls this, locally and on CI.

show_help()
{
  cat <<'EOF'
Usage: bin/rubocop-lint.sh [OPTIONS] <app-dir>

Lints the ruby source in <app-dir> with rubocop, using that dir's
.rubocop.yml, and writes junit xml to <app-dir>/reports/rubocop/junit.xml
for CI to attest to Kosli.

Options:
  -h    Show this help

Example:
  bin/rubocop-lint.sh app-dashboard
EOF
}

if [ "${1:-}" = '-h' ]; then
  show_help
  exit 0
fi

if [ $# -ne 1 ]; then
  show_help
  exit 1
fi

readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# The app dir holds .rubocop.yml beside the code it lints, so rubocop reads
# the config's relative paths against the right tree.
readonly APP_DIR="${REPO_ROOT}/${1}"
readonly REPORTS_DIR="${APP_DIR}/reports/rubocop"

if [ ! -f "${APP_DIR}/.rubocop.yml" ]; then
  echo "ERROR: ${APP_DIR}/.rubocop.yml does not exist" >&2
  exit 1
fi

rm -rf "${REPORTS_DIR}" &> /dev/null || true
mkdir -p "${REPORTS_DIR}"

# As the invoking user, so junit.xml belongs to whoever ran this rather than to
# the container's user. A file owned by someone else breaks kosli attest, which
# copies evidence with PreserveOwner and cannot chown to another uid.
#
# That user has no home dir, so rubocop's cache resolves to /.cache, which it
# cannot create. Caching is off: the cache would die with the container anyway.
#
# The image is built for linux/amd64 only; naming that platform stops docker
# warning about it on arm64 hosts.
DOCKER_CLI_HINTS=false docker run \
  --rm \
  --platform linux/amd64 \
  --user "$(id -u):$(id -g)" \
  --volume "${REPORTS_DIR}/:/reports/" \
  --volume "${APP_DIR}:/app" \
  cyberdojo/rubocop \
  --raise-cop-error \
  --cache false \
  --format=progress \
  --format=junit \
  --out=/reports/junit.xml
