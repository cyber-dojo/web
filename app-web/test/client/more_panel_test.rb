require_relative 'client_test_base'

# The ... panel covers only the page's counts column, so the page stays usable
# while it is out. A dialog opened from one of its rows covers the page too,
# so only then does the scrim dim and disable the page behind it.
class MorePanelTest < ClientTestBase

  test 'Mp4nZ1', %w(
  | the ... panel slides out with no scrim over the page, and the scrim
  | appears once one of its rows opens a dialog
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_more_panel
    refute_selector('#more-scrim', visible: true)

    find('#help-button').click
    assert_selector('#help-dialog[open]', wait: 5)
    assert_selector('#more-scrim', visible: true)
  end

  test 'Mp4nZ2', %w(
  | a dialog's [X] closes the dialog and slides the ... panel back, taking
  | the scrim with it
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_more_panel
    find('#help-button').click
    assert_selector('#help-dialog[open]', wait: 5)

    find('#help-dialog .dialog-close').click
    refute_selector('#help-dialog[open]', wait: 5)
    refute_selector('body.more-open', wait: 5)
    refute_selector('#more-scrim', visible: true)
  end
end
