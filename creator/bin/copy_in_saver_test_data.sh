
copy_in_saver_test_data()
{
  local -r SRC_PATH=$(repo_root)/creator/test/data
  local -r SAVER_CID="$(service_container saver)"
  local -r DEST_PATH=/cyber-dojo

  # You cannot docker cp to a tmpfs, so tar-piping instead...
  pushd ${SRC_PATH}/cyber-dojo
  tar -c . | docker exec -i "${SAVER_CID}" tar x -C ${DEST_PATH}
  popd
  # Push full-group to make test d4Px24 route_enter_test.rb much faster
  docker exec -i "${SAVER_CID}" tar xz -C / < "${SRC_PATH}/full-group-FD6ryx.tgz"
}
