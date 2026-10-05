require_relative 'client_test_base'

# The review page answers the kata page's Alt-J, Alt-K and Alt-O hotkeys: the
# next and previous file in its list, and between the output and its file.
class ReviewHotkeysTest < ClientTestBase

  test 'Hk7rQ2', %w(
  | in review, Alt-J selects the next listed file, Alt-K the previous one,
  | and Alt-O moves between the output tab and the filename tab
  ) do
    id = kata_with_one_test_run
    visit "/review/show/#{id}?now_index=2&diff=simple"
    assert_selector('#review-page .tab.filename.selected', text: 'hiker.sh', wait: 5)
    listed = all('#diff-filenames .diff-filename').map(&:text)
    at = listed.index('hiker.sh')

    alt('j')
    assert_selected_tab_filename(listed[(at + 1) % listed.size])
    alt('k')
    assert_selected_tab_filename('hiker.sh')

    alt('o')
    assert_selector('#review-page .tab.output.selected', wait: 5)
    assert_selector('#file-content-output', visible: true)
    alt('o')
    assert_selected_tab_filename('hiker.sh')
    refute_selector('#file-content-output', visible: true)
  end

  test 'Hk7rQ3', %w(
  | on the edit page in review mode, Alt-J selects the review page's next
  | listed file, and Alt-T runs no tests
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    all('#kata-page #traffic-lights img.diff-traffic-light').last.click
    assert_selector('#review-page .tab.filename.selected', text: 'hiker.sh', wait: 5)
    listed = all('#diff-filenames .diff-filename').map(&:text)
    at = listed.index('hiker.sh')

    alt('j')
    assert_selected_tab_filename(listed[(at + 1) % listed.size])

    # [test] disables itself the moment a run starts, and stays so until the
    # run's response, which takes far longer than this wait.
    assert_selector('#test-button:not([disabled])', visible: :all)
    count = saver.kata_events(id).size
    alt('t')
    sleep 0.5
    assert_selector('#test-button:not([disabled])', visible: :all)
    assert_equal count, saver.kata_events(id).size, 'Alt-T in review mode runs no tests'
  end

  private

  # Presses Alt with the given key outside any editor, where the document's
  # hotkey handler (cd.setupHotkeys) acts on it.
  def alt(key)
    find('body').send_keys([:alt, key])
  end

  def assert_selected_tab_filename(filename)
    assert_selector('#review-page .tab.filename.selected', exact_text: filename, wait: 5)
    assert_selector('#review-page .diff-filename.selected', exact_text: filename)
  end
end
