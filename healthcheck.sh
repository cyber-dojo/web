#!/bin/bash -Eeu

# Default Alpine image has wget (but not curl)

# Dockerfile has this
# HEALTHCHECK \
#    --interval=1s --timeout=1s --retries=5 --start-period=5s \
#    CMD ./heathcheck.sh

# --interval=S     time until 1st healthcheck
# --timeout=S      fail if single healthcheck takes longer than this
# --retries=N      number of tries until container considered unhealthy
# --start-period=S grace period when healthcheck fails dont count towards --retries

readonly PORT="${CYBER_DOJO_WEB_PORT}"
readonly READY_LOG_FILENAME=/tmp/ready.log

wget localhost:${PORT}/ready -q -O - > "${READY_LOG_FILENAME}" 2>&1

# keep only most recent 500 lines
sed -i '501,$ d' "${READY_LOG_FILENAME}"
