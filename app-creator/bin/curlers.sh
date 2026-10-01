
curl_tmpdir="$(mktemp -d)"
curl_log_filename() { echo -n "${curl_tmpdir}/creator.log"; }
curl_cleanup()
{
    local -r exit_code=$?
    # On a non-zero exit dump the last request's log to aid debugging - but only
    # if a request actually ran and wrote it. An early exit (eg the docker-daemon
    # check in app-creator/bin/demo.sh) leaves no log, and cat/rm on the missing file
    # would print their own spurious "No such file or directory" errors.
    if [ "${exit_code}" != "0" ] && [ -f "$(curl_log_filename)" ]; then
      cat "$(curl_log_filename)"
      rm "$(curl_log_filename)"
    fi
    rm -rf "${curl_tmpdir}"
}
trap "curl_cleanup" EXIT
# These requests run inside the creator container, against creator itself on
# the IPv4 loopback. So no host port is needed, and nginx's /creator/ rate
# limits are not in the way. The address is 127.0.0.1, not localhost: in the
# container localhost resolves to ::1 first, where puma is not listening. The image has BusyBox wget but no curl. The app mounts itself
# at /creator and serves nothing at the root, so the URLs below carry that
# prefix - see App::MOUNT_PATH, which this script cannot reach.
creator_url() { echo -n "http://127.0.0.1:${CYBER_DOJO_CREATOR_PORT}/creator/${1}"; }
tab() { printf '\t'; }

# Runs wget in the creator container with the given arguments. -S writes the
# response headers (eg HTTP/1.1 200 OK) to stderr and the body goes to stdout,
# so the log holds the headers followed by the body. wget exits non-zero on
# any status other than 2xx.
creator_wget()
{
  docker exec "$(service_container creator)" \
    wget -S -q -O - "$@" > "$(curl_log_filename)" 2>&1
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_json_body_200()
{
  local -r type="${1}"   # eg GET|POST
  local -r route="${2}"  # eg ready
  local -r json="${3:-}" # eg '{"display_name":"Java Countdown, Round 1"}'

  local post_data=()
  if [ "${type}" = 'POST' ]; then
    post_data=(--post-data "${json}")
  fi

  creator_wget \
    --header 'Content-type: application/json' \
    --header 'Accept: application/json' \
    "${post_data[@]}" \
    "$(creator_url "${route}")"

  grep --quiet 200 "$(curl_log_filename)"             # eg HTTP/1.1 200 OK
  local -r result=$(tail -n 1 "$(curl_log_filename)") # eg {"sha":"78c19640aa43ea214da17d0bcb16abed420d7642"}
  echo "$(tab)${type} ${route} => 200 ${result}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - -
curl_200()
{
  local -r route="${1}"   # eg choose_problem
  local -r pattern="${2}" # eg Content-Type: text/html

  creator_wget "$(creator_url "${route}")"

  grep --quiet 200 "$(curl_log_filename)" # eg HTTP/1.1 200 OK
  local -r result=$(grep "${pattern}" "$(curl_log_filename)" | head -n 1)
  echo "$(tab)GET ${route} => 200 ...|${result}"
}
