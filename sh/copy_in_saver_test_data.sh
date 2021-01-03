
# - - - - - - - - - - - - - - - - - - -
copy_in_saver_test_data()
{
  local -r SAVER_CID="$(saver_cid)"
  local -r SRC_PATH=${ROOT_DIR}/test/data/cyber-dojo
  local -r DEST_PATH=/cyber-dojo
  # Empty the /cyber-dojo dir ready for tar-pipe
  docker exec "${SAVER_CID}" bash -c 'rm -rf /cyber-dojo/groups/*'
  docker exec "${SAVER_CID}" bash -c 'rm -rf /cyber-dojo/katas/*'
  # You cannot docker cp to a tmpfs, so tar-piping instead...
  cd ${SRC_PATH} \
    && tar -c . \
    | docker exec -i ${SAVER_CID} tar x -C ${DEST_PATH}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
saver_cid()
{
  # locally, the container name is model_saver_1
  # on CI the contains name is, eg, project_saver_1_1bebf84ac62f
  docker ps --filter status=running --format '{{.Names}}' | grep "saver"
}
