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
# latest is resolved here, to the tag github's releases/latest redirect points
# at. That tag is the image tag: the release workflow hands the same string to
# its docker build.
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
    # The image tags are the CLI's git tags, which carry a leading v. The
    # release binary prints that tag, v and all; a homebrew-built kosli
    # prints the version bare. Add the v here, once, when it is missing.
    echo "v${version#v}"
    return
  fi
  local -r url=https://github.com/kosli-dev/cli/releases/latest
  # curl reports where the redirect points, rather than this reading the header
  # that says so. Header lines are CRLF-terminated, and a tag carrying the
  # trailing carriage return reaches docker as an invalid image reference.
  local -r location="$(curl --silent --head --output /dev/null --write-out '%{redirect_url}' "${url}")"
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

# Fetches the rego policy that decides whether a metrics report is within the
# limits in its params file, writing it to the file named by the caller.
#
# The URL lives here alone. .github/workflows/main.yml fetches the policy too,
# for 'kosli evaluate trail', and calls this through bin/fetch_metrics_policy.sh
# rather than curling its own copy, so the two cannot come to name different
# policies. Where the file goes stays the caller's choice.
#
# Both callers fetch rather than hand the URL to the CLI, which accepts one:
# main.yml attaches the fetched file to the decision it attests, so the bytes
# recorded are the bytes evaluated.
fetch_metrics_policy()
{
  local -r filename="${1}"
  local -r url=https://raw.githubusercontent.com/cyber-dojo/kosli-attestation-types/main/metrics-compliance.rego
  if ! curl --silent --show-error --fail-with-body --output "${filename}" "${url}"; then
    # --fail-with-body has written the error response to the file. Remove it, so
    # nothing downstream can evaluate an error page, and stop: a policy that did
    # not arrive cannot judge anything.
    rm -f "${filename}"
    stderr "ERROR: cannot fetch the metrics policy from ${url}"
    exit_non_zero
  fi
}

# Echoes the metrics report wrapped in the shape the policy reads it from: the
# trail as 'kosli evaluate trail' would present it in CI, holding one artifact,
# holding one attestation, whose attestation_data is the report.
#
# The two names are read from the params file, which is where the policy reads
# them too, so here they always agree with themselves. That makes the artifact
# and attestation names plumbing rather than something this check tests: a wrong
# name still passes locally and is caught only by CI, whose trail is real. What
# is tested locally is the report against the bounds.
metrics_policy_input()
{
  local -r report_filename="${1}"
  local -r params_filename="${2}"
  jq --slurpfile params "${params_filename}" '
    $params[0] as $p |
    { trail: { compliance_status: { artifacts_statuses:
      { ($p.artifact_name): { attestations_statuses:
        { ($p.attestation_name): { attestation_data: . } } } } } } }
  ' "${report_filename}"
}

# Checks one of the run's metrics reports against the limits in its params file.
# Takes the metrics' name, eg 'coverage' or 'test', from which the report and
# the params both follow. Requires echo_env_vars.sh to have been sourced, for
# repo_root.
#
# The check is the rego policy .github/workflows/main.yml evaluates, run here by
# the kosli CLI from its published image. The bounds are written once, in the
# params file; this makes the decision made from them written once too, so a
# local pass means what a CI pass means.
check_metrics()
{
  local -r metrics="${1}"                    # eg coverage
  check_metrics_files \
    "$(repo_root)/reports/${metrics}_metrics.json" \
    "$(repo_root)/test/${metrics}_metrics_params.json"
}

# Checks the given metrics report against the bounds in the given params file.
# Both are named absolutely, and both must live inside the repo: the CLI reads
# them from a read-only mount of the repo root, so they are handed to it named
# relative to that.
#
# Requires echo_metrics_bounds_table.sh to have been sourced, for the table it
# prints before evaluating.
check_metrics_files()
{
  local -r report="${1#"$(repo_root)/"}"                       # data from a test run
  local -r params="${2#"$(repo_root)/"}"                       # the bounds
  local -r policy=metrics-compliance.rego                      # how to judge one against the other

  exit_non_zero_unless_file_exists "$(repo_root)/${report}"
  exit_non_zero_unless_file_exists "$(repo_root)/${params}"

  fetch_metrics_policy "$(repo_root)/${policy}"

  # Every bound and how the run measures against it, which the CLI's own output
  # cannot show: the policy reports only the bounds that failed. Printed before
  # the evaluation so the verdict stays the last thing said.
  echo_metrics_bounds_table "$(repo_root)/${report}" "$(repo_root)/${params}"
  echo

  # Assigned on its own line so a failure to resolve stops the run. See
  # kosli_cli_image_tag.
  local tag
  tag="$(kosli_cli_image_tag)"

  # --assert and --output table are today's defaults, named anyway: evaluate is
  # a beta command, and a check that stopped failing, or started printing json,
  # because a default moved would be found the hard way.
  metrics_policy_input "$(repo_root)/${report}" "$(repo_root)/${params}" \
    | docker run \
        --read-only \
        --rm \
        --interactive \
        --volume "$(repo_root):/work:ro" \
        --workdir /work \
          "ghcr.io/kosli-dev/cli:${tag}" \
            evaluate input \
              --policy "${policy}" \
              --params "@${params}" \
              --assert \
              --output table
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
