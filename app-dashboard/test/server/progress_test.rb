require_relative 'test_base'
require_relative 'saver_data_builder'
require 'json'

class ProgressTest < TestBase
  include SaverDataBuilder

  # - - - - - - - - - - - - - - - - -

  test 'p2g5s1', %w(
  | GET /progress/<group-id> returns one entry per joined avatar, carrying its
  | kata id, avatar index, latest colour and the progress string matched out of
  | that run's output. An avatar that has only joined still appears, with the
  | colour 'create' of its creation event.
  ) do
    group_id = create_group('Bash, bats')
    ran_kata_id = join_avatar(group_id)
    give_traffic_light(ran_kata_id)
    joined_kata_id = join_avatar(group_id)

    index_of = saver_get('group_joined', { id: group_id })
               .to_h { |index, o| [o['id'], index.to_i] }

    get mounted_path("progress/#{group_id}"), {}, { 'HTTP_ACCEPT' => 'application/json' }
    assert status?(200), "status=#{status}"

    expected = [
      { 'id' => ran_kata_id, 'avatar_index' => index_of[ran_kata_id],
        'colour' => 'green', 'progress' => '' },
      { 'id' => joined_kata_id, 'avatar_index' => index_of[joined_kata_id],
        'colour' => 'create', 'progress' => '' }
    ]
    by_index = ->(katas) { katas.sort_by { |kata| kata['avatar_index'] } }
    assert_equal by_index.call(expected),
                 by_index.call(JSON.parse(last_response.body)['katas'])
  end
end
