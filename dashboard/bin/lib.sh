#!/usr/bin/env bash
set -Eeu

# Each app in this repo runs its containers as its own compose project, so one
# app's test run or demo never stops or finds another app's containers.
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-dashboard}"

readonly TMP_DIR="$(mktemp -d /tmp/dashboard.XXXXXXX)"
remove_tmp_dir() { rm -rf "${TMP_DIR}" > /dev/null; }
trap remove_tmp_dir INT EXIT

image_sha()
{
  git rev-parse HEAD
}

repo_root()
{
  git rev-parse --show-toplevel
}

image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

containers_down()
{
  # Names the same files demo.sh runs nginx from, so down knows the nginx
  # service and also removes the one-off container that run leaves.
  docker compose \
    --file "$(repo_root)/docker-compose-depends.yml" \
    --file "$(repo_root)/docker-compose-nginx.yml" \
    --file "$(repo_root)/docker-compose.yml" \
    down --remove-orphans --volumes
}

remove_old_images()
{
  echo Removing old images
  # grep exits non-zero when the machine holds no dashboard image, eg one whose
  # images have just been cleared, so an empty list must not end the build.
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep dashboard || true)
  remove_all_but_current "${dil}" "${CYBER_DOJO_DASHBOARD_CLIENT_IMAGE}"
  remove_all_but_current "${dil}" "${CYBER_DOJO_DASHBOARD_IMAGE}"
  remove_all_but_current "${dil}" cyberdojo/dashboard
  # Reclaim the dangling layers left behind by removing the old tagged images
  # above. Use 'docker image prune' (dangling images only), NOT 'docker system
  # prune', which would also wipe the BuildKit build cache and so force the
  # asset_builder FROM stage to be re-pulled and re-compiled on every build.
  docker image prune --force
}

# Keeps this commit's tag, which names the build just made. Every older tag
# goes, and an earlier build whose last tag was one of those goes with it.
remove_all_but_current()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  # Its own name, not image_name: bash locals are dynamically scoped, and
  # build_image declares image_name readonly before calling this.
  local tagged_name
  for tagged_name in $(echo "${docker_image_ls}" | grep "${name}:" || true)
  do
    if [ "${tagged_name}" != "${name}:${CYBER_DOJO_DASHBOARD_TAG}" ]; then
      docker image rm --force "${tagged_name}" || echo "  skipped ${tagged_name} (in use)"
    fi
  done
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "${filename} does not exist"
    exit_non_zero
  fi
}

exit_non_zero_unless_installed()
{
  for dependent in "$@"
  do
    if ! installed "${dependent}" ; then
      stderr "${dependent} is not installed!"
      exit_non_zero
    fi
  done
}

installed()
{
  if hash "${1}" &> /dev/null; then
    true
  else
    false
  fi
}

service_container()
{
  # Echo the container id of the given docker-compose service within this
  # app's compose project, COMPOSE_PROJECT_NAME (exported at the top of this
  # file).
  local -r service="${1}"
  docker ps \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
    --filter "label=com.docker.compose.service=${service}" \
    --format '{{.ID}}'
}

# Ends the script, non-zero. Not kill -INT $$: the INT trap above runs
# remove_tmp_dir, which does not exit, so bash ran the handler and then carried
# on from where it was - a caller reporting FAILED would keep going and the
# script would still exit 0.
exit_non_zero()
{
  exit 42
}

stderr()
{
  local -r message="${1}"
  >&2 echo "ERROR: ${message}"
}

copy_in_saver_test_data()
{
  local -r SAVER_CID="$(service_container saver)"
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  # The v2 tgz is piped directly into the container to avoid macOS case-insensitive
  # filesystem collapsing case-distinct directory names (e.g. katas/Ks/ and katas/ks/).

  # tar-pipe v0 and v1 katas from the host into the saver container
  tar --no-xattrs -c -C "${ROOT_DIR}/test/data" cyber-dojo \
    | docker exec -i ${SAVER_CID} tar x -C /

  # tar-pipe v2 katas directly into the saver container, bypassing the host filesystem.
  # Timestamps in events.json are rewritten on the fly to simulate a session starting now.
  ruby "${ROOT_DIR}/bin/rewrite_demo_timestamps.rb" \
    < "${ROOT_DIR}/test/data/saver_data.v2.tgz" \
    | docker exec -i ${SAVER_CID} tar --no-xattrs -zxf - -C /

  # tar-pipe the pre-baked demo cluster (3 LTFs, one child group each) the same
  # way. Baked by bin/create_cluster_data.sh; its id is in test/data/demo_cluster_id.txt.
  ruby "${ROOT_DIR}/bin/rewrite_demo_timestamps.rb" \
    < "${ROOT_DIR}/test/data/saver_cluster.v2.tgz" \
    | docker exec -i ${SAVER_CID} tar --no-xattrs -zxf - -C /
}

echo_warnings()
{
  local -r SERVICE_NAME="${1}" # {client|server}
  local -r DOCKER_LOG=$(docker logs "${CONTAINER_NAME}" 2>&1)
  # Handle known warnings (eg waiting on Gem upgrade)
  # local -r SHADOW_WARNING="server.rb:(.*): warning: shadowing outer local variable - filename"
  # DOCKER_LOG=$(strip_known_warning "${DOCKER_LOG}" "${SHADOW_WARNING}")

  if echo "${DOCKER_LOG}" | grep --quiet "warning" ; then
    echo "Warnings in ${SERVICE_NAME} container"
    echo "${DOCKER_LOG}"
  fi
}

strip_known_warning()
{
  local -r DOCKER_LOG="${1}"
  local -r KNOWN_WARNING="${2}"
  local -r STRIPPED=$(echo -n "${DOCKER_LOG}" | grep --invert-match -E "${KNOWN_WARNING}")
  if [ "${DOCKER_LOG}" != "${STRIPPED}" ]; then
    echo "Known service start-up warning found: ${KNOWN_WARNING}"
  else
    echo "Known service start-up warning NOT found: ${KNOWN_WARNING}"
    exit_non_zero
  fi
  echo "${STRIPPED}"
}
