#!/usr/bin/env bash
set -Eeu

if [[ "${1:-}" == '-h' ]]; then
  cat << 'HELP'
Usage: bin/create_cluster_data.sh

Bakes the demo cluster into test/data/saver_cluster.v2.tgz (and writes its
cluster id to test/data/demo_cluster_id.txt) so the demo can tar-pipe it
straight into the saver instead of creating it live each loop.

Spins up a throwaway saver container (its /cyber-dojo tmpfs starts empty),
creates a 3-LTF cluster in it (5 avatars per child group, each with 3-6
random red/amber/green traffic-lights - see bin/create_cluster_kata.rb),
snapshots its whole /cyber-dojo tree into the tgz, then removes the container.

Unlike a live demo, this needs no running stack; it uses the saver image
pinned by bin/echo_env_vars.sh (via versioner).

Example:
  bin/create_cluster_data.sh
HELP
  exit 0
fi

readonly ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${ROOT_DIR}/bin/lib.sh"
source "${ROOT_DIR}/bin/echo_env_vars.sh"
export $(echo_env_vars)

exit_non_zero_unless_installed docker

readonly BAKER=dashboard-cluster-baker
readonly DST_TGZ="${ROOT_DIR}/test/data/saver_cluster.v2.tgz"
readonly DST_ID="${ROOT_DIR}/test/data/demo_cluster_id.txt"

remove_baker() { docker rm --force "${BAKER}" >/dev/null 2>&1 || true; }
trap remove_baker EXIT

# Start a throwaway saver whose /cyber-dojo tmpfs starts empty, so the snapshot
# contains only the cluster we are about to create (nothing else).
remove_baker
docker run \
  --detach \
  --name "${BAKER}" \
  --init \
  --user saver \
  --env "CYBER_DOJO_SAVER_PORT=${CYBER_DOJO_SAVER_PORT}" \
  --tmpfs "/cyber-dojo:uid=19663,gid=65533" \
  --tmpfs "/tmp:uid=19663,gid=65533" \
  "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}" \
  >/dev/null

echo -n "Waiting for throwaway saver to be ready ..."
ready_probe() {
  docker exec "${BAKER}" ruby -e \
    "require 'net/http'; exit(Net::HTTP.get_response(URI('http://localhost:${CYBER_DOJO_SAVER_PORT}/ready')).code == '200' ? 0 : 1)" \
    >/dev/null 2>&1
}
for _ in $(seq 1 30); do
  if ready_probe; then break; fi
  echo -n .
  sleep 1
done
if ! ready_probe; then
  echo " FAILED"
  docker logs "${BAKER}"
  exit_non_zero
fi
echo " ok"

echo -n "Creating 3-LTF cluster (5 avatars each, 3-6 traffic-lights) ..."
CLUSTER_ID=$(docker exec --interactive "${BAKER}" ruby - < "${ROOT_DIR}/bin/create_cluster_kata.rb")
readonly CLUSTER_ID
echo " ${CLUSTER_ID}"

echo "Snapshotting /cyber-dojo into ${DST_TGZ} ..."
docker exec "${BAKER}" tar -zcf - -C / cyber-dojo > "${DST_TGZ}"

echo "${CLUSTER_ID}" > "${DST_ID}"
echo "Done. Cluster id ${CLUSTER_ID} written to ${DST_ID}"
