#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly SH_DIR="$(repo_root)/sh"
source "${SH_DIR}/echo_versioner_env_vars.sh"
export $(echo_versioner_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
main()
{
  echo 'API:k8s probing'
  curl_200 GET /alive?
  curl_200 GET /ready?
  curl_200 GET /sha
  echo
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_200()
{
  local -r log=/tmp/web_probe.log
  local -r type="${1}"   # eg GET|POST
  local -r route="${2}"  # eg repler/ready
  curl  \
    --fail \
    --request "${type}" \
    --silent \
    --verbose \
      "http://localhost:$(port)/${route}" \
      > "${log}" 2>&1

  grep --quiet 200 "${log}"             # eg HTTP/1.1 200 OK
  local -r result=$(tail -n 1 "${log}") # eg {"sha":"78c19640aa43ea214da17d0bcb16abbd420d7642"}
  echo "$(tab)${type} ${route} => 200 ${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { printf 80; }
tab() { printf '\t'; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
main
