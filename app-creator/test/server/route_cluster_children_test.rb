require_relative 'creator_test_base'

class RouteClusterChildrenTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest ClCh12: %w[
    |GET /cluster_children for a multi-LTF cluster id
    |returns one child per group
    |each carrying the group's id and its LTF display_name
  ] do
    language_names = languages_start_points.names.first(2)
    json_post mounted_path('create.json'), {
      exercise_name: exercises_start_points.names.first,
      language_names: language_names,
      type: 'cluster'
    }
    cluster_id = json_response['id']
    groups = cluster_manifest(cluster_id)['groups']

    assert_get_200_json('cluster_children', { id: cluster_id }) do |response|
      children = response['children']
      assert_equal groups.keys, children.map { |child| child['id'] }, children
      assert_equal language_names, children.map { |child| child['display_name'] }, children
    end
  end

end
