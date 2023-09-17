#!/usr/bin/env bash
set -Eeu

export KOSLI_FLOW=web

# KOSLI_ORG is set in CI
# KOSLI_API_TOKEN is set in CI
# KOSLI_HOST_STAGING is set in CI
# KOSLI_HOST_PRODUCTION is set in CI
# SNYK_TOKEN is set in CI

# - - - - - - - - - - - - - - - - - - -
kosli_create_flow()
{
  local -r hostname="${1}"

  kosli create flow "${KOSLI_FLOW}" \
    --description="UX for practicing TDD" \
    --host="${hostname}" \
    --template=artifact,branch-coverage,snyk-scan \
    --visibility=public
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_artifact()
{
  local -r hostname="${1}"

  kosli report artifact "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}" \
      --repo-root="$(root_dir)"
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_coverage_evidence()
{
  local -r hostname="${1}"

  kosli report evidence artifact generic "$(artifact_name)" \
      --artifact-type=docker \
      --description="server & client branch-coverage reports" \
      --name="branch-coverage" \
      --user-data="$(coverage_json_path)" \
      --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_report_snyk()
{
  local -r hostname="${1}"

  kosli report evidence artifact snyk "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}" \
      --name=snyk-scan \
      --scan-results="$(root_dir)/snyk.json"
}

# - - - - - - - - - - - - - - - - - - -
kosli_assert_artifact()
{
  local -r hostname="${1}"

  kosli assert artifact "$(artifact_name)" \
      --artifact-type=docker \
      --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_expect_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"

  # In .github/workflows/main.yml deployment is its own job
  # and the image must be present to get its sha256 fingerprint.
  docker pull "$(artifact_name)"

  kosli expect deployment "$(artifact_name)" \
    --artifact-type=docker \
    --description="Deployed to ${environment} in Github Actions pipeline" \
    --environment="${environment}" \
    --host="${hostname}"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_create_flow()
{
  if on_ci; then
    kosli_create_flow "${KOSLI_HOST_STAGING}"
    kosli_create_flow "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_artifact()
{
  if on_ci; then
    kosli_report_artifact "${KOSLI_HOST_STAGING}"
    kosli_report_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_report_coverage_evidence()
{
  if on_ci; then
    write_coverage_json
    kosli_report_coverage_evidence "${KOSLI_HOST_STAGING}"
    kosli_report_coverage_evidence "${KOSLI_HOST_PRODUCTION}"
  fi
}

on_ci_kosli_report_snyk_scan_evidence()
{
  if on_ci; then
    set +e
    snyk container test "$(artifact_name)" \
      --json-file-output="$(root_dir)/snyk.json" \
      --policy-path="$(root_dir)/.snyk"
    set -e

    kosli_report_snyk "${KOSLI_HOST_STAGING}"
    kosli_report_snyk "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
artifact_name()
{
  source "$(root_dir)/sh/echo_versioner_env_vars.sh"
  export $(echo_versioner_env_vars)
  echo "${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
root_dir()
{
  git rev-parse --show-toplevel
}

# - - - - - - - - - - - - - - - - - - -
write_coverage_json()
{
  {
    echo '{ "server":'
    cat "$(root_dir)/tmp/coverage/server/coverage.json"
    echo ', "client":'
    cat "$(root_dir)/tmp/coverage/client/coverage.json"
    echo '}'
  } > "$(coverage_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
coverage_json_path()
{
  echo "$(root_dir)/test/evidence.json"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}


