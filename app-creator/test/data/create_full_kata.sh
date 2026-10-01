#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
SH_DIR="$(repo_root)/app-creator/bin"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_down.sh"
source "${SH_DIR}/containers_up_healthy_and_clean.sh"
source "${SH_DIR}/curlers.sh"
source "${SH_DIR}/echo_env_vars.sh"
source "${SH_DIR}/remove_old_images.sh"

# shellcheck disable=SC2046
export $(echo_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
reset_saver()
{
  local -r saver_cid="${1}"
  docker exec "${saver_cid}" bash -c 'cd /cyber-dojo/groups && rm -rf *'
  docker exec "${saver_cid}" bash -c 'cd /cyber-dojo/katas && rm -rf *'
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
create_full_kata()
{
  local -r saver_cid="$(service_container saver)"

  reset_saver "${saver_cid}"
  curl_json_body_200 POST create.json \
    '{"exercise_name":"Fizz Buzz", "language_name":"Bash, bats", "type":"group"}'

  local -r json=$(tail -n 1 "$(curl_log_filename)") # eg {"route":"/creator/enter?id=K4n72X","id":"K4n72X"}
  local -r quoted_gid=$(jq ".id" <<< "${json}")     # eg "K4n72X"
  local -r gid="${quoted_gid:1:6}"                  # eg K4n72X

  for _ in {1..64}; do
    curl_json_body_200 POST enter.json "{\"id\":${quoted_gid}}"
  done
  echo "gid=${gid}"

  # Tar-pipe /cyber-dojo out of saver container
  # tar-file compression is not done inside the container
  # because `tar -z` fails in a read-only file-system
  local -r filename="$(repo_root)/app-creator/test/data/full-group-${gid}.tgz"
  local -r src_dir="/cyber-dojo/"
  docker exec "${saver_cid}" tar -cf - -C "$(dirname ${src_dir})" "$(basename ${src_dir})" \
    | gzip > "${filename}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
remove_old_images
build_tagged_images
server_up_healthy_and_clean
client_up_healthy_and_clean "$@"
create_full_kata
