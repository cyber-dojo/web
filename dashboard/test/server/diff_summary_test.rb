require_relative 'test_base'
require_relative 'saver_data_builder'
require 'json'

class DiffSummaryTest < TestBase
  include SaverDataBuilder

  # - - - - - - - - - - - - - - - - -

  test 'd1f5s1', %w(
  | GET /diff_summary returns one entry per file, naming it and counting its
  | added, deleted and unchanged lines between the two given event indexes
  ) do
    group_id = create_group('Bash, bats')
    kata_id = join_avatar(group_id)
    edit_a_file(kata_id)

    get mounted_path("diff_summary?id=#{kata_id}&was_index=0&now_index=1"),
        {}, { 'HTTP_ACCEPT' => 'application/json' }
    assert status?(200), "status=#{status}"

    diffs = JSON.parse(last_response.body)['diff_summary']
    by_name = diffs.to_h { |diff| [diff['new_filename'], diff] }
    assert_equal %w[cyber-dojo.sh hiker.sh], by_name.keys.sort, diffs

    hiker = by_name['hiker.sh']
    assert_equal 'changed', hiker['type'], hiker
    assert_equal({ 'added' => 2, 'deleted' => 0, 'same' => 1 },
                 hiker['line_counts'], hiker)
    assert_equal 'unchanged', by_name['cyber-dojo.sh']['type'], by_name
  end
end
