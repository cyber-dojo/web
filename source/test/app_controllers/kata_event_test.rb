require_relative 'app_controller_test_base'

class KataEventTest < AppControllerTestBase

  test 'G3C9D1a', %w(
  | event returns the kata event at the given index
  ) do
    in_kata do
      get '/kata/event', { id: @id, index: 0 }
      assert last_response.ok?
      assert_equal @manifest['visible_files'], json['event']['files']
    end
  end

end
