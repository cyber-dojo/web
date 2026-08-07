require_relative 'controllers_test_base'

class ForkTest < ControllersTestBase

  test 'F1B7Ce', %w(
  | /kata/fork still forks a kata. A review page loaded before the fork
  | button moved to the /fork prefix holds JavaScript posting here, and
  | such a tab can stay open for hours. This alias, and its test, can go
  | once those tabs are gone.
  ) do
    in_kata do
      post '/kata/fork', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.kata_exists?(json['kata_fork'])
    end
  end

  test 'F1B7Cf', %w(
  | /group/fork still forks a group, for the same already-open tabs as
  | the alias above.
  ) do
    in_kata do
      post '/group/fork', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.group_exists?(json['group_fork'])
    end
  end

  test 'F1B7Cc', %w(
  | /fork/kata returns the id of a new kata
  ) do
    in_kata do
      post '/fork/kata', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.kata_exists?(json['kata_fork'])
    end
  end

  test 'F1B7Cd', %w(
  | /fork/group returns the id of a new group
  ) do
    in_kata do
      post '/fork/group', { id: @id, index: 0 }
      assert last_response.ok?
      assert saver.group_exists?(json['group_fork'])
    end
  end

end
