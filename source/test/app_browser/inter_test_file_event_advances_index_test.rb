require_relative 'browser_test_base'

class InterTestFileEventAdvancesIndexTest < BrowserTestBase

  test 'fEv5A1', %w(
  | an inter-test file event advances the browser index by ADOPTING the
  | saver-returned next_index (setIndex(newIndex) in _file_inter_test_events.erb),
  | never by a local increment: after creating a file, the hidden index field
  | equals the saver's committed head + 1.
  ) do
    id = saver.kata_create(starter_manifest)
    visit "/kata/edit/#{id}"
    wait_for_index_field('1') # page load sets index to events.length

    # Invoke the real production inter-test handler (the [+] file-create button
    # calls exactly this), rather than driving the file-menu/prompt UI.
    execute_script(%q{cd.fileCreateITE('scratch.txt', function(){});})

    head_next = wait_until_index_field_matches_saver(id)
    assert_operator head_next, :>, 1, 'the file event should have advanced the head'
  end

  private

  # The file event is async: the saver commits, then the browser's .then runs
  # setIndex(newIndex). Poll until the hidden index field has adopted the saver's
  # committed head + 1. Returns that value so the caller can assert it advanced.
  def wait_until_index_field_matches_saver(id)
    head_next = nil
    30.times do
      head_next = saver.kata_events(id).last['index'] + 1
      return head_next if head_next > 1 && index_field_value == head_next.to_s
      sleep 0.5
    end
    flunk "index field #{index_field_value.inspect} never matched saver head+1 (#{head_next})"
  end

end
