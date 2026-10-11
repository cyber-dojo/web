require_relative 'client_test_base'

# When review opens on a light whose diff has no changes, as after a [test]
# with no edits, it picks the file the kata page is showing, if that file is
# at the light, then a test file, the largest if several, then cyber-dojo.sh.
class ReviewPickFileTest < ClientTestBase

  test 'Pk7nF1', %w(
  | review opened from the kata page on a light with no changes
  | picks the file the kata page is showing
  ) do
    id = kata_with_one_unedited_test_run(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    find('#filename-list .filename', exact_text: 'hiker.sh').click
    all('#traffic-lights img.diff-traffic-light').last.click
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)
  end

  test 'Pk7nF2', %w(
  | review opened from a dashboard on a light with no changes
  | picks a test file, as there is no kata page file
  ) do
    id = kata_with_one_unedited_test_run(starter_manifest)
    visit "/review/show/#{id}?now_index=1"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'test_hiker.sh', wait: 5)
  end

  test 'Pk7nF3', %w(
  | review opened from a dashboard on a light with no changes
  | picks the largest test file when there are several
  ) do
    manifest = starter_manifest
    lines = (1..12).map { |n| "@test \"answer is #{n}\" {\n  [ \"$(answer)\" == \"42\" ]\n}\n" }
    manifest['visible_files']['hiker_tests.sh'] = { 'content' => lines.join("\n") }
    id = kata_with_one_unedited_test_run(manifest)
    visit "/review/show/#{id}?now_index=1"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker_tests.sh', wait: 5)
  end

  private

  # A kata whose only event after creation is a red test run of its
  # unedited files, so the run's diff has no changes.
  def kata_with_one_unedited_test_run(manifest)
    id = saver.kata_create(manifest)
    files = saver.kata_event(id, 0)['files']
    kata_ran_tests(id, files, content('out'), content('err'), 0,
                   ran_summary('red'), laptop_id, next_tab_seq)
    id
  end
end
