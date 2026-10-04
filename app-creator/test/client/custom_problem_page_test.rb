require_relative 'browser_test_base'

# The custom-problem page creates a practice the same way the setup page does:
# a solo practice's [start] opens its kata in a new tab, and a group practice's
# [create] goes to its enter page.
class CustomProblemPageTest < BrowserTestBase

  # - - - - - - - - - - - - - - - - -

  qtest Cp4mT1: %w[
    |solo custom problem: titled as a solo practice, and [start] opens
    |the new kata's edit page in a new tab
  ] do
    visit(mounted_path('choose_custom_problem?type=kata'))
    assert_selector('.title', exact_text: 'create a new solo practice')
    find('.display-name', match: :first).click
    new_tab = window_opened_by { find('button.next', exact_text: 'start').click }
    within_window(new_tab) do
      # The tab opens blank and reaches the kata only once create.json returns.
      assert_current_path(%r{\A/kata/edit/[0-9A-Za-z]{6}\z}, wait: 10)
      assert kata_exists?(current_path.split('/').last)
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Cp4mT2: %w[
    |group custom problem: titled as a group practice, and [create] goes
    |to the new group's enter page
  ] do
    visit(mounted_path('choose_custom_problem?type=group'))
    assert_selector('.title', exact_text: 'create a new group practice')
    find('.display-name', match: :first).click
    find('button.next', exact_text: 'create').click
    assert_current_path(%r{\A/creator/enter\?id=[0-9A-Za-z]{6}\z})
    assert group_exists?(current_url.split('id=').last)
  end
end
