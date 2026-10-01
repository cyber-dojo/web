
# Returns the absolute path of the repo's root directory.
repo_root() { git rev-parse --show-toplevel; }

# Echoes the versioner image's env-var statements (image names, SHAs, TAGs,
# and PORTs for every cyber-dojo service). The versioner image is the single
# source of truth for these; redirect its stderr to hide platform warnings.
run_versioner()
{
  docker run --rm --platform linux/amd64 cyberdojo/versioner:latest >/tmp/log.stdout 2>/tmp/log.stderr
  cat /tmp/log.stdout
}

# Generates .env and echoes the env-vars needed for docker-compose ${...}
# substitution. Port numbers come solely from the versioner image, so .env
# never duplicates (and cannot drift from) that single source of truth.
echo_env_vars()
{
  local -r commit_sha="$(cd "$(repo_root)" && git rev-parse HEAD)"
  local -r image_tag="${commit_sha:0:7}"

  source "$(repo_root)/bin/write_dot_env.sh"
  write_dot_env

  #--------------------
  # Set env-vars for this repo

  echo DOCKER_CLI_HINTS=false

  run_versioner
  #
  echo CYBER_DOJO_CREATOR_IMAGE=cyberdojo/creator
  echo CYBER_DOJO_CREATOR_SHA="${commit_sha}"
  echo CYBER_DOJO_CREATOR_TAG="${image_tag}"
  #
  echo CYBER_DOJO_CREATOR_SERVER_USER=nobody

  # Here you can add SHA/TAG env-vars for any service whose
  # local repos you have edited, have new git commits in,
  # and have built new images from. Their build scripts
  # finish by printing echo env-var statements you need to
  # add to this function if you want the new images to be
  # part of the dev-loop/demo. For example:
  #
  # echo CYBER_DOJO_SAVER_SHA=fef7a58e2eb3c3b16c51ef0f2c71fc6b7bfb53af
  # echo CYBER_DOJO_SAVER_TAG=fef7a58
}
