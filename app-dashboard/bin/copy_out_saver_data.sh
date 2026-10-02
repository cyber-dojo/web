#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: bin/copy_out_saver_data.sh GID

Appends group GID, and every kata in its katas.txt, from the running demo's
saver to test/data/saver_data.v2.tgz. Run this after creating demo data with
bin/create_group_kata.sh to persist it for future demo runs.

Only that group and its katas are added. The demo's saver also holds every
other app's demo data (eg the demo cluster, creator's full group, fresh v2
katas), which already have their own tgz files or are throwaway, so a snapshot
of the whole saver would duplicate them into this file on every run.

The merge is done by bin/merge_tgz.rb, so it needs ruby but not any one tar.

The saver container of the running demo must be up.
See bin/create_group_kata.sh -h for the full step-by-step workflow.

Example:
  bin/copy_out_saver_data.sh zuejz2
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"

exit_non_zero_unless_installed docker ruby

readonly GID="${1:?usage: bin/copy_out_saver_data.sh GID}"
readonly DST_TGZ_FILENAME="${ROOT_DIR}/test/data/saver_data.v2.tgz"
readonly NEW_TGZ_FILENAME="${DST_TGZ_FILENAME}.new"
readonly CONTAINER="$(service_container saver)"

# Inside the saver: tar the group's dir and the dir of each kata in its
# katas.txt (lines are "<kata-id> <avatar-index>"). Ids are stored split
# into three 2-char dirs, eg zuejz2 at groups/zu/ej/z2.
echo_group_tgz()
{
  docker exec "${CONTAINER}" sh -c '
    set -e
    split() { echo "$1" | sed "s|^\(..\)\(..\)\(..\)$|\1/\2/\3|"; }
    cd /
    group="cyber-dojo/groups/$(split "$1")"
    paths="${group}"
    while read -r kata_id _avatar_index; do
      paths="${paths} cyber-dojo/katas/$(split "${kata_id}")"
    done < "${group}/katas.txt"
    tar -zcf - ${paths}
  ' sh "${GID}"
}

# Merge the existing tgz's entries with the new group's into a new tgz, then
# replace the old one only once the merge has succeeded.
echo_group_tgz \
  | ruby "${ROOT_DIR}/bin/merge_tgz.rb" "${DST_TGZ_FILENAME}" \
  > "${NEW_TGZ_FILENAME}"
mv "${NEW_TGZ_FILENAME}" "${DST_TGZ_FILENAME}"
