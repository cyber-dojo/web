require_relative 'app_controller_test_base'

class ForkTest < AppControllerTestBase

  test 'F1B7Ca', %w(
  | kata_fork returns the id of a new kata
  ) do
    in_kata do
      post '/kata/fork', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.kata_exists?(json['kata_fork'])
    end
  end

  test 'F1B7Cb', %w(
  | group_fork returns the id of a new group
  ) do
    in_kata do
      post '/group/fork', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.group_exists?(json['group_fork'])
    end
  end

end
