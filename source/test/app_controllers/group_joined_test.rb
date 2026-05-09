require_relative 'app_controller_test_base'

class GroupJoinedTest < AppControllerTestBase

  test 'H4E6F2a', %w(
  | joined returns the avatars that have joined a group kata
  ) do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    kid = saver.group_join(gid)
    get '/group_joined', { id: gid }
    assert last_response.ok?
    assert_equal 1, json.size
    assert_equal kid, json.values.first['id']
  end

end
