require_relative 'creator_test_base'

class RouteIdTypeTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest qedx22: %w[
    |GET /id_type
    |has status 200
    |returns 'cluster'
    |when id is of an existing cluster
  ] do
    args = {
      exercise_name: exercises_start_points.names.first,
      language_names: languages_start_points.names.first(2),
      type: 'cluster'
    }
    json_post mounted_path('create.json'), args
    cluster_id = json_response['id']

    assert_get_200_json('id_type', { id: cluster_id }) do |response|
      assert_equal ['id_type'], response.keys, last_response.body
      assert_equal 'cluster', response['id_type']
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest qedx23: %w[
    |GET /id_type
    |has status 200
    |returns 'group'
    |when id is of an existing group
  ] do
    args = { id: 'chy6BJ' }
    assert_get_200_json('id_type', args) do |response|
      assert_equal ['id_type'], response.keys, last_response.body
      id_type = response['id_type']
      assert_equal 'group', id_type
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest qedx24: %w[
    |GET /id_type
    |has status 200
    |returns 'single'
    |when id is of an existing kata
  ] do
    args = { id: '5rTJv5' }
    assert_get_200_json('id_type', args) do |response|
      assert_equal ['id_type'], response.keys, last_response.body
      id_type = response['id_type']
      assert_equal 'single', id_type
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest qedx25: %w[
    |GET /id_type
    |has status 200
    |returns nil
    |when id is neither a group nor a kata
  ] do
    args = { id: 'x1y2z3' }
    assert_get_200_json('id_type', args) do |response|
      assert_equal ['id_type'], response.keys, last_response.body
      id_type = response['id_type']
      assert_nil id_type
    end
  end
end
