#!/bin/sh

# See https://github.com/docker/compose/issues/1393
# See http://stackoverflow.com/questions/35022428
rm -f /app/tmp/pids/server.pid

rails server \
  --environment=production