require_relative 'client_test_base'

# In review, detailed diff mode shows a test run's output. Event 0 (the kata's
# creation) has no output, so stepping back to it must not show one.
class ReviewCreationEventOutputTest < ClientTestBase

  test 'd5f2a1', %w(
  | in detailed review mode, stepping back from a test run to event 0
  | shows no output, since the kata's creation has none
  ) do
    id = saver.kata_create(starter_manifest)
    files = saver.kata_event(id, 0)['files']
    # The edit commits a file_edit (event 1) under the test run (event 2); a
    # file event is what enables detailed mode.
    files['hiker.sh']['content'] = files['hiker.sh']['content'].sub('6 * 9', '6 * 7')
    kata_ran_tests(id, files, content('out'), content('err'), 0,
                   ran_summary('red'), laptop_id, next_tab_seq)

    visit "/review/show/#{id}?now_index=2"
    find('label[for="detailed"]').click
    assert_selector('#file-content-output', visible: true, wait: 5)

    find('#prev-index').click
    wait_for_review_index(1)
    find('#prev-index').click
    wait_for_review_index(0)
    # The index moves at once; the files and then the output refresh after it.
    refute_selector('#file-content-output', visible: true, wait: 5)
  end

  private

  # Waits until the review page has moved to the given event index, since each
  # [<] click refreshes the page asynchronously.
  def wait_for_review_index(index)
    page.document.synchronize(5) do
      unless evaluate_script('cd.review.index') == index
        raise Capybara::ElementNotFound, "review index is not #{index}"
      end
    end
  end
end
