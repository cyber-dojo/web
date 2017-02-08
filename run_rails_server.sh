#!/bin/sh

# See https://github.com/docker/compose/issues/1393
rm -f /app/tmp/pids/server.pid

rails server --environment=production