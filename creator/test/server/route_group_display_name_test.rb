require_relative 'creator_test_base'

class RouteGroupDisplayNameTest < CreatorTestBase

  qtest Gd5n40: %w[
    |GET /group_display_name for a group id
    |returns the group's LTF display_name
  ] do
    language_name = languages_start_points.names.first
    json_post mounted_path('create.json'), {
      language_name: language_name,
      exercise_name: exercises_start_points.names.first,
      type: 'group'
    }
    group_id = json_response['id']
    assert group_exists?(group_id), "id:#{group_id}:"

    assert_get_200_json('group_display_name', { id: group_id }) do |response|
      assert_equal language_name, response['display_name'], response
    end
  end

end
