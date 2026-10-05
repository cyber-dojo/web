require_relative 'client_test_base'

# Settings is a row in the ... panel. Only the kata page offers it: a review
# page has no settings to change, whether reached from a dashboard or by
# switching to review mode on the edit page.
class SettingsEntryTest < ClientTestBase

  test 'St3vB1', %w(
  | on the edit page the ... panel has a settings row, which opens the
  | settings dialog
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_more_panel
    assert_selector('#settings-button', visible: true)
    find('#settings-button').click
    assert_selector('#settings-dialog[open]', wait: 5)
  end

  test 'St3vB2', %w(
  | a review page reached from a dashboard has no settings row in its
  | ... panel
  ) do
    id = kata_with_one_test_run
    visit "/review/show/#{id}"
    assert_selector('#review-page .tab.filename.selected', wait: 5)
    open_more_panel
    assert_selector('#help-button', visible: true)
    refute_selector('#settings-button', visible: true)
  end

  test 'St3vB3', %w(
  | on the edit page, switching to review mode drops the settings row from
  | the ... panel, and [resume] brings it back
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    all('#kata-page #traffic-lights img.diff-traffic-light').last.click
    assert_selector('#review-page .tab.filename.selected', wait: 5)
    open_more_panel
    assert_selector('#help-button', visible: true)
    refute_selector('#settings-button', visible: true)

    close_more_panel
    find('#resume-button').click
    assert_selector('#kata-page', visible: true, wait: 5)
    open_more_panel
    assert_selector('#settings-button', visible: true)
  end
end
