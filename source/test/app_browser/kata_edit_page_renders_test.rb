require_relative 'browser_test_base'

class KataEditPageRendersTest < BrowserTestBase

  test 'bR9pQ2', %w(
  | the kata edit page loads in a real browser and its on-load JavaScript runs:
  | a freshly created v2 kata has only the index-0 event, so edit.erb's
  | setIndex(events.length) sets the hidden index field to 1.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    # edit.erb's setIndex(events.length) runs in JS on load; a fresh kata has
    # only the index-0 event, so the hidden index field becomes "1".
    wait_for_index_field('1')
  end

end
