require_relative 'app_controller_test_base'

class KataOptionTest < AppControllerTestBase

  test 'A5C3Ea', %w(
  | option_get returns the current value for a kata option
  ) do
    in_kata do
      get '/kata/option_get', { id: @id, name: 'colour' }
      assert last_response.ok?
      assert json.key?('kata_option_get')
    end
  end

  test 'A5C3Eb', %w(
  | option_set persists a value that option_get then returns
  ) do
    in_kata do
      post '/kata/option_set', { id: @id, name: 'colour', value: 'off' }
      assert last_response.ok?

      get '/kata/option_get', { id: @id, name: 'colour' }
      assert_equal 'off', json['kata_option_get']
    end
  end

end
