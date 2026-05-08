require_relative 'app_controller_test_base'

class KataDiffTest < AppControllerTestBase

  test 'B6E3Fa', %w(
  | GET /kata/diff_summary returns the changed file
  ) do
    in_kata do
      @files[@files.keys.first] += "\n# change"
      post_run_tests
      now_index = saver.kata_events(@id).last['index']
      get '/kata/diff_summary', { id: @id, was_index: 0, now_index: now_index }
      assert last_response.ok?
      assert_equal 1, json['diff_summary'].count { |d| d['type'] != 'unchanged' }
    end
  end

  test 'B6E3Fb', %w(
  | GET /kata/diff_lines returns the changed file
  ) do
    in_kata do
      @files[@files.keys.first] += "\n# change"
      post_run_tests
      now_index = saver.kata_events(@id).last['index']
      get '/kata/diff_lines', { id: @id, was_index: 0, now_index: now_index }
      assert last_response.ok?
      assert_equal 1, json['diff_lines'].count { |d| d['type'] != 'unchanged' }
    end
  end

end
