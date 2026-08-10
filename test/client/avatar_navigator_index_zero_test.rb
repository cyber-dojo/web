require_relative 'client_test_base'

# The review page's avatar-navigator locates the avatar under review among its
# group's active avatars and enables the prev/next buttons around it. Avatar
# index 0 (alligator) is the boundary case: the navigator's "no such neighbour"
# sentinel is '', and 0 == '' is true in JavaScript, so index 0 reads as absent.
# A group only meets this when saver hands out index 0 (model.rb group_join
# defaults to indexes:AVATAR_INDEXES.shuffle), which is why it is intermittent.
class AvatarNavigatorIndexZeroTest < ClientTestBase

  test '9d41c7', %w(
  | the review page of the avatar at index 0 shows the avatar-navigator,
  | the same as every other avatar in its group
  ) do
    gid = saver.group_create(starter_manifest)
    id0 = ran_one_test(join_at(gid, 0))
    ran_one_test(join_at(gid, 13))

    visit "/review/show/#{id0}"

    assert_selector '#avatar-navigator', wait: 5
  end

  test '9d41c8', %w(
  | the avatar after index 0 can navigate back to it - its prev-avatar button
  | is enabled, rather than the avatar being treated as the group's first
  ) do
    gid = saver.group_create(starter_manifest)
    ran_one_test(join_at(gid, 0))
    id13 = ran_one_test(join_at(gid, 13))

    visit "/review/show/#{id13}"
    assert_selector '#avatar-navigator', wait: 5

    refute_selector '#prev-avatar[disabled]'
  end

  private

  # Joins the group at exactly the given avatar index and returns the new kata's
  # id. group_join normally lets saver pick from AVATAR_INDEXES.shuffle; saver's
  # HTTP layer splats the posted JSON into keyword args (app_base.rb json_result),
  # so a one-element indexes list pins the index and keeps these tests
  # deterministic instead of waiting on a lucky shuffle.
  def join_at(gid, index)
    saver.instance_variable_get(:@http).post(:group_join, { id: gid, indexes: [index] })
  end

  # Runs one test in the kata, so the avatar has an event beyond its index-0
  # 'created' event and so counts as active in the group_joined read the
  # navigator does. Returns the kata id, for chaining onto join_at.
  def ran_one_test(id)
    files = saver.kata_event(id, 0)['files']
    kata_ran_tests(id, files, content('out'), content('err'), 0,
                   ran_summary('red'), laptop_id, next_tab_seq)
    id
  end
end
