require_relative 'creator_test_base'

class RouteGroupJoinedTest < CreatorTestBase

  qtest Gj7k41: %w[
    |GET /group_joined for a group two avatars have joined
    |returns each joined avatar's index mapped to its kata id
  ] do
    group_id = create_group
    joined = 2.times.to_h do
      json_post mounted_path('enter.json'), { id: group_id }
      [json_response['group_index'].to_s, json_response['id']]
    end
    assert_get_200_json('group_joined', { id: group_id }) do |response|
      assert_equal({ 'avatars' => joined }, response)
    end
  end

  qtest Gj7k42: %w[
    |GET /group_joined for a group no avatar has joined yet
    |returns no avatars
  ] do
    group_id = create_group
    assert_get_200_json('group_joined', { id: group_id }) do |response|
      assert_equal({ 'avatars' => {} }, response)
    end
  end

  private

  # Returns the id of a new, unjoined group, created through create.json.
  def create_group
    json_post mounted_path('create.json'), {
      language_name: languages_start_points.names.first,
      exercise_name: exercises_start_points.names.first,
      type: 'group'
    }
    group_id = json_response['id']
    assert group_exists?(group_id), "id:#{group_id}:"
    group_id
  end

end
