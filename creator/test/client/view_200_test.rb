require_relative 'browser_test_base'

class View200Test < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest a97d13: %w[home] do
    visit('/')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
    visit('/creator/home')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d16: %w[choose_problem] do
    visit('/creator/choose_problem')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d17: %w[choose_custom_problem] do
    visit('/creator/choose_custom_problem')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d18: %w[choose_ltf] do
    exercise_name = any_exercises_start_points_display_name
    visit("/creator/choose_ltf?exercise_name=#{exercise_name}")
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d20: %w[enter] do
    visit('/creator/enter?id=chy6BJ')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d21: %w[reenter] do
    visit('/creator/reenter?id=chy6BJ')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d22: %w[full] do
    visit('/creator/full?id=chy6BJ')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end
end
