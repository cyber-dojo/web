#!/usr/bin/env bash
set -Eeu

# Docker settings every script in bin/ wants, set here so no script repeats
# them. Sourcing this file is enough; scripts sourced alongside it share the
# same shell and so inherit them too.
#
# CLI_HINTS silences the "What's next:" banner docker prints after a run.
# DEFAULT_PLATFORM silences "requested image's platform does not match host
# platform" on Apple Silicon. The images are amd64, which docker-compose.yml
# pins for every service.
export DOCKER_CLI_HINTS=false
export DOCKER_DEFAULT_PLATFORM=linux/amd64

exit_non_zero_unless_installed()
{
  printf "Checking ${1} is installed..."
  if ! installed "${1}" ; then
    stderr "ERROR: ${1} is not installed!"
    exit_non_zero
  fi
  if [ "${1}" == docker ]; then
    set +e
    docker run --rm cyberdojo/versioner:latest > /tmp/cyber-dojo.env-vars 2>&1
    local -r STATUS=$?
    set -e
    if [ "${STATUS}" != "0" ]; then
      stderr ERROR: docker not working
      cat /tmp/cyber-dojo.env-vars
      exit_non_zero
    fi
  fi
  echo It is
  if [ "${1}" == docker ]; then
    echo_ci_resolved_versions
  fi
}

# Echoes the tag of the kosli CLI image that check_metrics runs, for
# 'make metrics_test' and 'make metrics_coverage'. Takes the version from
# KOSLI_CLI_VERSION, the same variable .github/workflows/main.yml passes to
# cyber-dojo/setup-kosli-cli, and defaults to the value that variable holds
# there: latest.
#
# The image has no latest tag to ask for. kosli-dev/cli pushes exactly one tag
# per build - the git tag on a release, an 8-char commit sha otherwise - so
# latest is resolved here, to the tag github's releases/latest redirect names in
# its location header. That tag is the image tag: the release workflow hands the
# same string to its docker build.
#
# Resolving it on each run is what makes this repo's checks use the CLI version
# main.yml uses, without a version number written down in either place.
#
# Callers must assign this on a line of its own:
#   local tag
#   tag="$(kosli_cli_image_tag)"
# Declaring and assigning together makes the exit status local's, not the
# substitution's, so a failure to resolve would arrive as an empty tag rather
# than as a stopped script.
kosli_cli_image_tag()
{
  local -r version="${KOSLI_CLI_VERSION:-latest}"
  if [ "${version}" != latest ]; then
    echo "${version}"
    return
  fi
  local -r url=https://github.com/kosli-dev/cli/releases/latest
  local -r location="$(curl --silent --head "${url}" | grep --ignore-case '^location:')"
  local -r tag="${location##*/tag/}"
  # check_metrics cannot evaluate anything without the CLI, and a check that
  # cannot run has decided nothing. Stop here, rather than let the caller reach
  # a docker pull of some tag assembled from an error page.
  if [ -z "${tag}" ] || [ "${tag}" == "${location}" ]; then
    stderr "ERROR: cannot resolve the latest kosli CLI version from ${url}"
    exit_non_zero
  fi
  echo "${tag}"
}

# Checks one of the run's metrics reports against its limits, by running the
# evaluator inside the app image so it uses the same ruby the tests do. Takes
# the metrics' name, eg 'coverage' or 'test', from which the report, the limits
# and the evaluator's argument all follow. Requires echo_env_vars.sh to have
# been sourced and its vars exported, for repo_root and the image name.
check_metrics()
{
  local -r metrics="${1}"                    # eg coverage
  local -r test_dir="$(repo_root)/test"
  local -r reports_dir="$(repo_root)/reports"
  local -r tmp=/tmp

  exit_non_zero_unless_file_exists "${test_dir}/check_metrics.rb"                  # evaluator
  exit_non_zero_unless_file_exists "${reports_dir}/${metrics}_metrics.json"        # data from the test run
  exit_non_zero_unless_file_exists "${test_dir}/${metrics}_metrics_params.json"    # the bounds

  docker run \
    --read-only \
    --rm \
    --entrypoint="" \
    --volume "${test_dir}/check_metrics.rb:${tmp}/check_metrics.rb:ro" \
    --volume "${reports_dir}/${metrics}_metrics.json:${tmp}/${metrics}_metrics.json:ro" \
    --volume "${test_dir}/${metrics}_metrics_params.json:${tmp}/${metrics}_metrics_params.json:ro" \
      "${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}" \
        sh -c "ruby ${tmp}/check_metrics.rb ${tmp}/${metrics}_metrics.json ${tmp}/${metrics}_metrics_params.json"
}

exit_non_zero_unless_file_exists()
{
  local -r filename="${1}"
  if [ ! -f "${filename}" ]; then
    stderr "ERROR: ${filename} does not exist!"
    exit_non_zero
  fi
}

echo_ci_resolved_versions()
{
  # On a CI run, print the versioner image's own repo digest and the service
  # image tags/digests it resolved into /tmp/cyber-dojo.env-vars. This makes
  # the exact versions under test visible in the CI log, so a versioner or
  # service version mismatch is diagnosable directly from the log rather than
  # by reconstructing registry push timelines. Does nothing off CI.
  if [ -z "${GITHUB_ACTIONS:-}" ]; then
    return
  fi
  local -r versioner_digest="$(docker inspect \
    --format '{{index .RepoDigests 0}}' \
    cyberdojo/versioner:latest 2>/dev/null || echo unknown)"
  echo "CI resolved versions (from cyberdojo/versioner:latest):"
  echo "  versioner = ${versioner_digest}"
  grep --extended-regexp '_(IMAGE|TAG|DIGEST)=' /tmp/cyber-dojo.env-vars || true
}

on_ci()
{
  # -n, not == true, so any non-empty CI counts. A guard reading this must fail
  # toward refusing to act, and CI=false is far likelier to mean a misconfigured
  # runner than a deliberate request to behave as if local.
  [ -n "${CI:-}" ]
}

installed()
{
  if hash "${1}" 2> /dev/null; then
    true
  else
    false
  fi
}

service_container()
{
  # Echo the container id of the given docker-compose service within
  # this demo's project. The project is COMPOSE_PROJECT_NAME (set by
  # bin/demo.sh), defaulting to web so the saver/test helpers work
  # against a plain demo when the var is not exported in the shell.
  local -r service="${1}"
  docker ps \
    --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME:-web}" \
    --filter "label=com.docker.compose.service=${service}" \
    --format '{{.ID}}'
}

stderr()
{
  >&2 echo "${1}"
}

exit_non_zero()
{
  exit 42
}
