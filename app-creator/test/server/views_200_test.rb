require_relative 'creator_test_base'

class Views200Test < CreatorTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  qtest a49AB0: %w[GET /home 200] do
    assert_get_200_html('home')
  end

  qtest a49AA0: %w[GET /choose_problem 200] do
    assert_get_200_html('choose_problem')
  end

  qtest a49AA1: %w[GET /choose_custom_problem 200] do
    assert_get_200_html('choose_custom_problem')
  end

  qtest a49AA2: %w[GET /choose_ltf 200] do
    exercise_name = exercises_start_points.names.sample
    assert_get_200_html('choose_ltf', exercise_name: exercise_name)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  qtest a49AC2: %w[GET /enter 200] do
    assert_get_200_html('enter', id: group_id)
    assert_get_200_html('enter', id: kata_id)
    assert_get_200_html('enter')
  end

  qtest a49AC3: %w[GET /avatar 200] do
    assert_get_200_html('avatar', id: kata_id)
  end

  qtest a49AC4: %w[GET /reenter 200] do
    assert_get_200_html('reenter', id: group_id)
  end

  qtest a49AC5: %w[GET /full 200] do
    assert_get_200_html('full', id: group_id)
  end

  private

  def group_id
    'chy6BJ'
  end

  def kata_id
    '5rTJv5'
  end
end
