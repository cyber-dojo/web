require_relative 'client_test_base'

# The review page has the kata page's two tabs over its diff sheet: the
# selected file's name, and a test run's output.
class ReviewTabsTest < ClientTestBase

  test 'Rt5mW1', %w(
  | review shows an output tab for a test run, and none for an event
  | without output, such as the file edit before it
  ) do
    id = kata_with_one_test_run

    visit "/review/show/#{id}?now_index=1"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)
    refute_selector('#review-page .tab.output', visible: true)

    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)
    assert_selector('#review-page .tab.output', visible: true, wait: 5)
  end

  test 'Rt5mW2', %w(
  | in review, the output tab shows the output, and the filename tab, or a
  | file in the list, returns to showing that file
  ) do
    id = kata_with_one_test_run
    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.output', visible: true, wait: 5)

    find('#review-page .tab.output').click
    assert_output_showing
    find('#review-page .tab.filename').click
    assert_file_showing('hiker.sh')

    find('#review-page .tab.output').click
    assert_output_showing
    find('#review-page .diff-filename', exact_text: 'cyber-dojo.sh').click
    assert_file_showing('cyber-dojo.sh')
  end

  test 'Rt5mW3', %w(
  | in review, both tabs carry the theme setting as a class, so with a
  | dark theme they are dark like the diff sheet they hang over
  ) do
    id = kata_with_one_test_run
    saver.kata_option_set(id, 'theme', 'dark')
    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.output', visible: true, wait: 5)

    assert_equal %w(tab filename dark selected), find('#review-page .tab.filename')[:class].split
    assert_equal %w(tab output dark), find('#review-page .tab.output')[:class].split
  end

  test 'Rt5mW4', %w(
  | on the edit page, switching the theme to dark also makes the review
  | page's tabs dark, so review mode opened afterwards matches the kata page
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    open_more_panel
    find('#settings-button').click
    assert_selector('#settings-dialog[open]', wait: 5)
    find('#settings-dialog label[for="dark"]').click
    find('#settings-dialog .dialog-close').click
    refute_selector('#settings-dialog[open]', wait: 5)
    refute_selector('body.more-open', wait: 5)

    all('#kata-page #traffic-lights img.diff-traffic-light').last.click
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)
    assert_selector('#review-page .tab.output', visible: true, wait: 5)

    assert_equal %w(tab filename dark selected), find('#review-page .tab.filename')[:class].split
    assert_equal %w(tab output dark), find('#review-page .tab.output')[:class].split
  end

  private

  def assert_output_showing
    assert_selector('#review-page .tab.output.selected', wait: 5)
    assert_selector('#file-content-output', visible: true)
    refute_selector('#review-page .diff-filename.selected')
  end

  def assert_file_showing(filename)
    assert_selector('#review-page .tab.filename.selected', exact_text: filename, wait: 5)
    assert_selector('#review-page .diff-filename.selected', exact_text: filename)
    refute_selector('#file-content-output', visible: true)
    assert_selector('#diff-content .file-content', visible: true, count: 1)
  end
end
