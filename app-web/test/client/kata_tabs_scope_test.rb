require_relative 'client_test_base'

# The edit page holds both the kata page and the review page, each with its
# own filename and output tabs. Selecting a file on the kata page names only
# the kata page's filename tab.
class KataTabsScopeTest < ClientTestBase

  test 'Ks8pY1', %w(
  | on the edit page, selecting a kata file leaves the review page's
  | filename tab naming the file review last showed
  ) do
    id = kata_with_one_test_run
    visit "/kata/edit/#{id}"
    wait_for_edit_page_ready
    assert_equal '', review_filename_tab_text, 'review has shown no file yet'

    all('#kata-page #traffic-lights img.diff-traffic-light').last.click
    assert_selector('#review-page .tab.filename.selected', exact_text: 'hiker.sh', wait: 5)
    find('#resume-button').click
    assert_selector('#kata-page', visible: true, wait: 5)

    find('[id="radio_cyber-dojo.sh"]').click
    assert_selector('#kata-page .tab.filename.selected', exact_text: 'cyber-dojo.sh', wait: 5)
    assert_equal 'hiker.sh', review_filename_tab_text
  end

  private

  # Read by script, since the review page is hidden while the kata page shows.
  def review_filename_tab_text
    evaluate_script("$('#review-page .tab.filename').text()")
  end
end
