require_relative 'browser_test_base'

class SetupPageTest < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa1: %w[
    |solo setup: start stays disabled until
    |both an exercise and a language-test-framework are chosen
  ] do
    visit(mounted_path('setup?type=kata'))
    assert_selector('button.next[disabled]')
    find('.exercises .display-name', exact_text: 'Tennis').click
    assert_selector('button.next[disabled]')
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    assert_selector('button.next:not([disabled])')
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa2: %w[
    |solo setup: start stays disabled after choosing
    |a language-test-framework until an exercise is chosen too
  ] do
    visit(mounted_path('setup?type=kata'))
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    assert_selector('button.next[disabled]')
    find('.exercises .display-name', exact_text: 'Tennis').click
    assert_selector('button.next:not([disabled])')
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa3: %w[
    |skip the exercise is offered only for a solo practice,
    |and ticking it counts as the exercise choice
  ] do
    visit(mounted_path('setup?type=group'))
    assert_no_selector('label.skip')
    visit(mounted_path('setup?type=kata'))
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    assert_selector('button.next[disabled]')
    find('label.skip').click
    assert_selector('button.next:not([disabled])')
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa4: %w[
    |a group practice chooses at most 5 language-test-frameworks
  ] do
    visit(mounted_path('setup?type=group'))
    find('.languages .display-name', exact_text: 'Python').click
    %w[assert behave pytest pytest-approval unittest unittest-approval].each do |framework|
      find('.frameworks .display-name', exact_text: framework).click
    end
    assert_selector('.ltfs-chosen .display-name.filled', count: 5)
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa5: %w[
    |the test-framework column lists exactly the frameworks
    |of the language last clicked
  ] do
    visit(mounted_path('setup?type=kata'))
    %w[Python Ruby].each do |language|
      find('.languages .display-name', exact_text: language).click
      expected = languages_start_points.names
        .select { |name| name.split(',', 2)[0] == language }
        .map { |name| name.split(',', 2)[1].strip }
      assert_equal expected, all('.frameworks .display-name').map(&:text)
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa6: %w[
    |unticking a chosen language-test-framework's checkbox
    |unchooses it, disabling start again
  ] do
    visit(mounted_path('setup?type=kata'))
    find('.exercises .display-name', exact_text: 'Tennis').click
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    assert_selector('button.next:not([disabled])')
    find('.ltfs-chosen .slot-num input').click
    assert_no_selector('.ltfs-chosen .display-name.filled')
    assert_selector('button.next[disabled]')
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa7: %w[
    |solo setup: start opens the new kata's edit page directly,
    |not the enter page that create.json's route names
  ] do
    visit(mounted_path('setup?type=kata'))
    find('.exercises .display-name', exact_text: 'Tennis').click
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    find('button.next').click
    assert_current_path(%r{\A/kata/edit/[0-9A-Za-z]{6}\z})
    assert kata_exists?(current_path.split('/').last)
  end
end
