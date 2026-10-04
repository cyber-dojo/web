require_relative 'browser_test_base'

class View200Test < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest a97d13: %w[home] do
    visit('/')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
    visit('/creator/home')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d16: %w[setup solo] do
    visit('/creator/setup?type=kata')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d17: %w[choose_custom_problem] do
    visit('/creator/choose_custom_problem')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d18: %w[setup group] do
    visit('/creator/setup?type=group')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end

  qtest a97d20: %w[enter] do
    visit('/creator/enter?id=chy6BJ')
    assert page.html.include?('<title>cyber-dojo</title>'), :failed_to_render
  end
end
