require_relative 'app_controller_test_base'

class KataEventsTest < AppControllerTestBase

  test 'C7B3F1a', %w(
  | events returns the kata events array
  ) do
    in_kata do
      get '/kata/events', { id: @id }
      assert last_response.ok?
      assert_equal 1, json['kata_events'].size
    end
  end

end
