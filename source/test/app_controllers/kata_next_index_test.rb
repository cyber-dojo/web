require_relative 'app_controller_test_base'

class KataNextIndexTest < AppControllerTestBase

  test 'q7F3a1', %w(
  | GET /kata/next_index/:id returns the next index the browser should hold:
  | on a freshly created kata (only the index-0 created event) that is 1.
  ) do
    in_kata do
      get '/kata/next_index/' + @id
      assert last_response.ok?, last_response.body
      assert_equal 1, json['next_index']
    end
  end

  test 'q7F3a2', %w(
  | GET /kata/next_index/:id returns last_committed_index + 1 after events
  | have been added, so a browser can resync to the committed head.
  ) do
    in_kata do
      post_run_tests               # adds a ran_tests event
      post_run_tests               # adds another
      last_index = saver.kata_events(@id).last['index']
      get '/kata/next_index/' + @id
      assert last_response.ok?, last_response.body
      assert_equal last_index + 1, json['next_index']
    end
  end

end
