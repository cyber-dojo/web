#!/bin/bash
set -e

# called from pipe_build_up_test.sh

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly KATA_IDS=(5A0F824303 420B05BA0A 420F2A2979 421F303E80 420BD5D5BE 421AFD7EC5)
readonly CONTAINER='test_web_cyber-dojo-storer'

. ${MY_DIR}/../../../.env

# make sure ${CYBER_DOJO_KATAS_ROOT} dir exists
docker exec \
  ${CONTAINER} \
    sh -c "mkdir -p ${CYBER_DOJO_KATAS_ROOT}"

# tar-pipe test data into storer's katas data-container
for KATA_ID in "${KATA_IDS[@]}"
do
  cat ${MY_DIR}/${KATA_ID}.tgz \
    | docker exec \
        --interactive \
          ${CONTAINER} \
            sh -c "tar -zxf - -C ${CYBER_DOJO_KATAS_ROOT}"
done

# set ownership of test-data in storer's katas data-container
docker exec \
    ${CONTAINER} \
      sh -c "chown -R cyber-dojo:cyber-dojo ${CYBER_DOJO_KATAS_ROOT}"
