#!/usr/bin/env bash
set -Eeu

repo_root() { git rev-parse --show-toplevel; }
readonly SH_DIR="$(repo_root)/sh"
source "${SH_DIR}/echo_env_vars.sh"
export $(echo_env_vars)

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
main()
{
  # See app/config/routes.rb
  echo 'API: probing'
  curl_200 GET /alive?
  curl_200 GET /ready?
  curl_200 GET /web/sha
  curl_200 GET /web/base_image
  echo
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_200()
{
  local -r log=/tmp/web_probe.log
  local -r type="${1}"   # eg GET|POST
  local -r route="${2}"  # eg repler/ready

  rm "${log}" >& /dev/null || true

  set +e
  HTTP_CODE=$(curl --header 'Content-Type: application/json' \
       --output "${log}" \
       --write-out "%{http_code}" \
       --request "${type}" \
       --silent \
      "http://localhost:$(port)/${route}")
  set -e

  if [[ ${HTTP_CODE} -lt 200 || ${HTTP_CODE} -gt 299 ]] ; then
      echo "$(tab)${type} ${route} => ${HTTP_CODE}"
      # cat "${log}"
      exit 42
  else
    echo "$(tab)${type} ${route} => 200"
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
port() { printf 80; }
tab() { printf '\t'; }

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
main
