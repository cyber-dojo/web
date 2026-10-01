
# - - - - - - - - - - - - - - - - - - -
server_up_healthy_and_clean()
{
  export SERVICE_NAME=creator
  docker compose up --detach "${SERVICE_NAME}"
  exit_non_zero_unless_healthy
}

# - - - - - - - - - - - - - - - - - - -
client_up_healthy_and_clean()
{
  if [ "${1:-}" != 'server' ]; then
    # What the browser tests need besides the creator container they run in.
    # The nginx image defines no HEALTHCHECK, so there is nothing to poll for;
    # --wait blocks until each service is running, and healthy too where the
    # image does define one.
    #
    # The browser tests load several pages in quick succession, each pulling
    # html plus app.css and app.js through /creator/, whose limit is sized for
    # a human at a keyboard. Only this run turns it up; anything else bringing
    # nginx up, the demo included, gets the production value from the image.
    export CYBER_DOJO_CREATOR_CHOOSE_RATE=6000r/m
    # The tests reach nginx over the compose network; this host port only
    # satisfies the nginx ports mapping. It differs from web's test run (9080)
    # so the two can run at once.
    export CYBER_DOJO_NGINX_HOST_PORT="${CYBER_DOJO_NGINX_HOST_PORT:-9081}"
    # --no-deps keeps nginx's demo-only dependencies (web, dashboard, differ)
    # out; creator is already up from server_up_healthy_and_clean.
    docker compose up --detach --wait --no-deps nginx selenium
    exit_non_zero_unless_selenium_grid_ready
  fi
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_selenium_grid_ready()
{
  # A healthy selenium container is not the same as a listening grid: the java
  # process binds 4444 a second or two after the container reports healthy, and
  # a test starting in that window dies with ECONNREFUSED. Ask the grid itself,
  # from the container the tests run in, so this proves the exact path they use.
  local -r cid="$(service_container creator)"
  local -r MAX_TRIES=100
  printf "Waiting until the selenium grid answers"
  for _ in $(seq ${MAX_TRIES})
  do
    if docker exec "${cid}" wget --quiet --output-document=- \
         http://selenium:4444/status >/dev/null 2>&1; then
      echo; echo "selenium grid is ready."
      return
    fi
    printf .
    sleep 0.1
  done
  echo; echo "selenium grid did not answer after ${MAX_TRIES} tries."
  exit_non_zero
}

# - - - - - - - - - - - - - - - - - - -
exit_non_zero_unless_healthy()
{
  echo
  local -r MAX_TRIES=50
  printf "Waiting until %s is healthy" "${SERVICE_NAME}"
  for _ in $(seq ${MAX_TRIES})
  do
    if healthy; then
      echo; echo "${SERVICE_NAME} is healthy."
      return
    else
      printf .
      sleep 0.1
    fi
  done
  echo; echo "${SERVICE_NAME} not healthy after ${MAX_TRIES} tries."
  echo_docker_log
  echo
  exit_non_zero
}

# - - - - - - - - - - - - - - - - - - -
healthy()
{
  # Containers are no longer given fixed names (so concurrent demos/tests in
  # sibling repos do not collide), so resolve the service's container id by
  # its compose project+service label - see service_container in lib.sh.
  local -r cid="$(service_container "${SERVICE_NAME}")"
  [ -n "${cid}" ] && \
    docker ps --filter health=healthy --format '{{.ID}}' | grep -q "${cid}"
}

# - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  # Dump the failed service's container log so a boot-crash is diagnosable in
  # CI. Resolve the container in any state (it has usually exited by now - see
  # service_container_any_state in lib.sh); a plain running-only lookup would
  # find nothing and 'docker logs' would print "invalid container name or ID:
  # value is empty", hiding exactly the crash we need to see.
  local -r cid="$(service_container_any_state "${SERVICE_NAME}")"
  if [ -n "${cid}" ]; then
    echo "===== docker log for ${SERVICE_NAME} (container ${cid}) ====="
    docker logs "${cid}" 2>&1
    echo "===== end docker log for ${SERVICE_NAME} ====="
  else
    echo "No container found for service '${SERVICE_NAME}' in compose" \
         "project '${COMPOSE_PROJECT_NAME}'. All project containers:"
    docker ps --all \
      --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
      --format 'table {{.Names}}\t{{.Status}}'
  fi
}
