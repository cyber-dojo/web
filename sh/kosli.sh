#!/usr/bin/env bash
set -Eeu

export KOSLI_ORG=cyber-dojo
export KOSLI_FLOW=web-ci
export KOSLI_TRAIL="$(git rev-parse HEAD)"

# KOSLI_ORG is set in CI
# KOSLI_API_TOKEN is set in CI
# KOSLI_API_TOKEN_STAGING is set in CI
# KOSLI_HOST_STAGING is set in CI
# KOSLI_HOST_PRODUCTION is set in CI
# SNYK_TOKEN is set in CI

# - - - - - - - - - - - - - - - - - - -
kosli_begin_trail()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli create flow "${KOSLI_FLOW}" \
    --description="UX for practicing TDD" \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --template-file="$(repo_root)/.kosli.yml" \
    --visibility=public

  kosli begin trail "${KOSLI_TRAIL}" \
    --host="${hostname}" \
    --api-token="${api_token}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_artifact()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli attest artifact "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --repo-root="$(repo_root)" \
    --name=web
}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_coverage_evidence()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli attest generic "$(artifact_name)" \
    --artifact-type=docker \
    --description="server & client branch-coverage reports" \
    --name=web.branch-coverage \
    --user-data="$(coverage_json_path)" \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --repo-root="$(repo_root)"
}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_snyk()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  echo "kosli attest snyk $(artifact_name) ..."
  
  kosli attest snyk "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --name=web.snyk-scan \
    --attachments="$(repo_root)/snyk.policy" \
    --scan-results="$(repo_root)/snyk.json" \
    --repo-root="$(repo_root)"
}

# - - - - - - - - - - - - - - - - - - -
kosli_assert_artifact()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli assert artifact "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_begin_trail()
{
  if on_ci; then
    kosli_begin_trail "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_begin_trail "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_artifact()
{
  if on_ci; then
    kosli_attest_artifact "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_artifact "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_coverage_evidence()
{
  if on_ci; then
    write_coverage_json
    kosli_attest_coverage_evidence "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_coverage_evidence "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_snyk_scan_evidence()
{
  if on_ci; then
    set +e
    snyk container test "$(artifact_name)" \
      --policy-path="$(repo_root)/snyk.policy" \
      --sarif \
      --sarif-file-output="$(repo_root)/snyk.json"
    set -e

    kosli_attest_snyk "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_snyk "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
artifact_name()
{
  source "$(repo_root)/sh/echo_versioner_env_vars.sh"
  export $(echo_versioner_env_vars)
  echo "${CYBER_DOJO_WEB_IMAGE}:${CYBER_DOJO_WEB_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
repo_root()
{
  git rev-parse --show-toplevel
}

# - - - - - - - - - - - - - - - - - - -
write_coverage_json()
{
  {
    echo '{ "server":'
    cat "$(repo_root)/tmp/coverage/server/coverage.json"
    echo ', "client":'
    cat "$(repo_root)/tmp/coverage/client/coverage.json"
    echo '}'
  } > "$(coverage_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
coverage_json_path()
{
  echo "$(repo_root)/test/evidence.json"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}


