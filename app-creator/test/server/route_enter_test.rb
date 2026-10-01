require_relative 'creator_test_base'

class RouteEnterTest < CreatorTestBase

  # - - - - - - - - - - - - - - - - -

  qtest d4Pj3K: %w[
    |POST /enter.json
    |for a version=2 group
    |has status 200
    |returns JSON with id,group_index and route to avatar page
  ] do
    json_post_create_group({
                             language_name: languages_start_points.names.sample,
                             exercise_name: exercises_start_points.names.sample
                           }) do |manifest|
      group_id = manifest['id']
      assert_post_200_json('enter.json', { id: group_id }) do |response|
        # eg response == {"route"=>"/creator/avatar?id=TEbR8E", "id"=>"TEbR8E", "group_index" => 51}
        assert response.key?('route'), response.keys
        assert %r{/creator/avatar\?id=(?<kata_id>.*)} =~ response['route'], response['route']
        assert response.key?('id'), response.keys
        assert_equal kata_id, response['id'], :kata_id
        assert kata_exists?(kata_id), "kata_exists?(#{kata_id})"
        assert response.key?('group_index'), response.keys
        group_index = response['group_index']
        assert group_index >= 0 && group_index < 64
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest d4Px24: %w[
    |POST /enter.json
    |for a version=2 group
    |has status 200
    |returns JSON with route to full page
    |when group is full
  ] do
    path = 'enter.json'
    # Use pre-created full group
    # See test/data/create_full_kata.sh
    # See sh/copy_in_saver_test_data.sh
    data = { id: 'FD6ryx' }
    assert_post_200_json(path, data) do |response|
      # eg response == {"route"=>"/creator/full?id=FxWwrr"}
      assert response.key?('route'), response.keys
      assert %r{/creator/full\?id=(?<kata_id>.*)} =~ response['route'], response['route']
      assert_equal 'FD6ryx', kata_id, :kata_id
    end
  end

  # - - - - - - - - - - - - - - - - -

  AVATAR_COUNT = 64

  qtest d4Pc36: %w[
    |POST /enter.json across every group of a multi-LTF cluster
    |spreads avatars so that filling the cluster to its 64-joiner capacity
    |hands out each of the 64 avatars exactly once across all its groups;
    |filling it a second time (to 128 joiners) hands out each avatar
    |exactly twice - no animal appears three times anywhere in the cluster
  ] do
    child_group_ids = json_post_create_cluster({
                                                 language_names: languages_start_points.names.first(2),
                                                 exercise_name: exercises_start_points.names.first
                                               })
    joins_per_group = AVATAR_COUNT / child_group_ids.size

    group_indexes = join_each_group(child_group_ids, joins_per_group)
    assert_equal (0...AVATAR_COUNT).to_a, group_indexes.sort, group_indexes

    group_indexes += join_each_group(child_group_ids, joins_per_group)
    assert_equal ((0...AVATAR_COUNT).to_a * 2).sort, group_indexes.sort, group_indexes
  end

  private

  def join_each_group(child_group_ids, joins_per_group)
    group_indexes = []
    child_group_ids.each do |child_group_id|
      joins_per_group.times do
        assert_post_200_json('enter.json', { id: child_group_id }) do |response|
          group_indexes << response['group_index']
        end
      end
    end
    group_indexes
  end

  def json_post_create_group(args)
    args[:type] = 'group'
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert group_exists?(id), "id:#{id}:" # eg "xCSKgZ"
    yield group_manifest(id)
  end

  def json_post_create_cluster(args)
    args[:type] = 'cluster'
    json_post mounted_path('create.json'), args
    id = json_response['id']
    assert cluster_exists?(id), "id:#{id}:"
    cluster_manifest(id)['groups'].keys
  end
end
