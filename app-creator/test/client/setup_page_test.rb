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
    |no exercise is offered for solo and group practices,
    |and ticking it counts as the exercise choice
  ] do
    %w[kata group].each do |type|
      visit(mounted_path("setup?type=#{type}"))
      find('.languages .display-name', exact_text: 'Python').click
      find('.frameworks .display-name', exact_text: 'pytest').click
      assert_selector('button.next[disabled]')
      find('label.skip').click
      assert_selector('button.next:not([disabled])')
    end
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
    |solo setup: start opens the new kata's edit page directly, in a new
    |tab, not the enter page that create.json's route names
  ] do
    visit(mounted_path('setup?type=kata'))
    find('.exercises .display-name', exact_text: 'Tennis').click
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    new_tab = window_opened_by { find('button.next').click }
    within_window(new_tab) do
      # The tab opens blank and reaches the kata only once create.json returns.
      assert_current_path(%r{\A/kata/edit/[0-9A-Za-z]{6}\z}, wait: 10)
      assert kata_exists?(current_path.split('/').last)
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Sp7qa8: %w[
    |group setup: 2 language-test-frameworks with the exercise skipped
    |creates a cluster whose child groups have no exercise
  ] do
    visit(mounted_path('setup?type=group'))
    find('.languages .display-name', exact_text: 'Python').click
    find('.frameworks .display-name', exact_text: 'pytest').click
    find('.frameworks .display-name', exact_text: 'behave').click
    find('label.skip').click
    find('button.next').click
    assert_current_path(%r{\A/creator/enter\?id=[0-9A-Za-z]{6}\z})
    id = current_url.split('id=').last
    assert cluster_exists?(id), id
    cluster_manifest(id)['groups'].each_key do |group_id|
      assert_equal '', group_manifest(group_id)['exercise'], group_id
    end
  end
end
