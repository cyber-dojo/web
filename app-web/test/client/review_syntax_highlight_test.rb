require_relative 'client_test_base'

# The review page syntax highlights the file it shows. Each side of a diff is
# highlighted as a whole file, the old one for deleted lines and the new one
# for added and same lines, so every line carries its own side's tokens.
class ReviewSyntaxHighlightTest < ClientTestBase

  test 'Sh8kQ1', %w(
  | in review with diff on, deleted, added and same lines of the shown
  | file are all syntax highlighted
  ) do
    id = kata_with_one_test_run
    visit "/review/show/#{id}?now_index=1&diff=simple"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)

    within(shown_sheet) do
      assert_selector('deleted', text: '6 * 9', count: 1)
      assert_selector('added', text: '6 * 7', count: 1)
      assert_selector('deleted .cm-builtin', exact_text: 'echo', count: 1)
      assert_selector('added .cm-builtin', exact_text: 'echo', count: 1)
      assert_selector('same .cm-meta', exact_text: '#!/bin/bash', count: 1)
    end
  end

  test 'Sh8kQ2', %w(
  | in review with diff off, the shown file is syntax highlighted
  ) do
    id = kata_with_one_test_run
    visit "/review/show/#{id}?now_index=2&diff=off"
    find('#review-page .diff-filename', exact_text: 'hiker.sh', wait: 5).click
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)

    within(shown_sheet) do
      refute_selector('deleted')
      refute_selector('added')
      assert_selector('same .cm-builtin', exact_text: 'echo', count: 1)
      assert_selector('same .cm-meta', exact_text: '#!/bin/bash', count: 1)
    end
  end

  test 'Sh8kQ3', %w(
  | in review, the shown file's sheet carries the CodeMirror theme class
  | of the theme and colour settings, so a dark theme gives a dark sheet
  ) do
    id = kata_with_one_test_run
    saver.kata_option_set(id, 'theme', 'dark')
    saver.kata_option_set(id, 'colour', 'off')
    visit "/review/show/#{id}?now_index=1&diff=simple"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)

    classes = shown_sheet[:class].split
    assert classes.include?('cm-s-cyber-dojo-dark-colour-off'), classes.inspect
  end

  test 'Sh8kQ4', %w(
  | in review, the shown file's content, holding both its line numbers and
  | its sheet, carries the theme setting as a class, so the line numbers
  | are styled for the same theme as the sheet beside them
  ) do
    id = kata_with_one_test_run
    saver.kata_option_set(id, 'theme', 'dark')
    visit "/review/show/#{id}?now_index=1&diff=simple"
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)

    classes = shown_file_content[:class].split
    assert_equal ['file-content', 'dark'], classes
  end

  private

  # The content of the one file review is showing: its line numbers and its
  # diff sheet side by side.
  def shown_file_content
    find('#diff-content .file-content', visible: true)
  end

  # The diff sheet of the one file review is showing; the other files'
  # sheets are in the page but hidden.
  def shown_sheet
    find('#diff-content .file-content .diff-sheet', visible: true)
  end
end
