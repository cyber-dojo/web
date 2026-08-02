require_relative 'app_controller_test_base'

class DiffTest < AppControllerTestBase

  # - - - - - - - - - - - - - - - -

  test 'C8B4E1', %w(
  | diff_lines() shows changed and unchanged files
  | between two traffic-light events
  ) do
    in_kata do
      post_run_tests # 1==ran-tests
      was_index = 1
      @files['hiker.sh'] = @files['hiker.sh'].sub('6 * 9', '6 * 7')
      post_run_tests # 2==file-edit, 3==ran-tests
      now_index = kata.events.last['index']

      get '/kata/diff_lines', { id: @id, was_index: was_index, now_index: now_index }
      assert last_response.ok?

      diffs = json['diff_lines']
      changed = diffs.select { |d| d['type'] == 'changed' }
      assert_equal 1, changed.size
      assert_equal 'hiker.sh', changed[0]['new_filename']
      assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 5 }, changed[0]['line_counts'])
      refute_nil changed[0]['lines']

      unchanged = diffs.select { |d| d['type'] == 'unchanged' }
      assert_equal 4, unchanged.size
    end
  end

  # - - - - - - - - - - - - - - - -

  test 'C8B4E2', %w(
  | diff_summary() shows changed and unchanged files
  | between two traffic-light events
  | but does not include line-level diff data
  ) do
    in_kata do
      post_run_tests # 1==ran-tests
      was_index = 1
      @files['hiker.sh'] = @files['hiker.sh'].sub('6 * 9', '6 * 7')
      post_run_tests # 2==file-edit, 3==ran-tests
      now_index = kata.events.last['index']

      get '/kata/diff_summary', { id: @id, was_index: was_index, now_index: now_index }
      assert last_response.ok?

      diffs = json['diff_summary']
      changed = diffs.select { |d| d['type'] == 'changed' }
      assert_equal 1, changed.size
      assert_equal 'hiker.sh', changed[0]['new_filename']
      assert_equal({ 'added' => 1, 'deleted' => 1, 'same' => 5 }, changed[0]['line_counts'])
      assert_nil changed[0]['lines']

      unchanged = diffs.select { |d| d['type'] == 'unchanged' }
      assert_equal 4, unchanged.size
    end
  end

end
