require_relative 'app_controller_test_base'

class KataOptionSetTest < AppControllerTestBase

  test 'D2A8F1a', %w(
  | option_set persists the value to saver
  ) do
    in_kata do
      post '/kata/option_set', { id: @id, name: 'colour', value: 'off' }
      assert last_response.ok?
      assert_equal 'off', saver.kata_option_get(@id, 'colour')

      post '/kata/option_set', { id: @id, name: 'colour', value: 'on' }
      assert last_response.ok?
      assert_equal 'on', saver.kata_option_get(@id, 'colour')
    end
  end

end
