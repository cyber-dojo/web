#!/bin/bash
set -e

# called from pipe_build_up_test.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly PARAM=${1:-test}
readonly KATA_IDS=(421F303E80)

exit 0

# TODO: tar-pipe-into storer. How?
# There is no volume at the moment

. ${MY_DIR}/../../env.${PARAM}

# tar-pipe test data into storer's katas data-container
for KATA_ID in "${KATA_IDS[@]}"
do
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker run \
        --rm \
        --interactive \
        --volumes-from ${CYBER_DOJO_KATA_DATA_CONTAINER_NAME}:rw \
          alpine:latest \
            sh -c "tar -zxf - -C ${CYBER_DOJO_KATAS_ROOT}"
done

# set ownership of test-data in storer's katas data-container
docker run \
  --rm \
  --volumes-from ${CYBER_DOJO_KATA_DATA_CONTAINER_NAME} \
    cyberdojo/storer \
      sh -c "cd /tmp/katas && chown -R cyber-dojo:cyber-dojo *"
