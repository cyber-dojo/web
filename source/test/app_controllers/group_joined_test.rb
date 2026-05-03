require_relative 'app_controller_test_base'

class GroupJoinedTest < AppControllerTestBase

  test 'H4E6F2a', %w(
  | joined returns the avatars that have joined a group kata
  ) do
    manifest = starter_manifest
    gid = saver.group_create(manifest)
    kid = saver.group_join(gid)
    get '/group/joined', { id: gid }
    assert last_response.ok?
    joined = json['joined']
    assert_equal 1, joined.size
    assert_equal kid, joined.values.first['id']
  end

end
