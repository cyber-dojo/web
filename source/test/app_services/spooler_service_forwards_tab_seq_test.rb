require_relative 'app_services_test_base'
require_relative 'http_json_requester_capturing_stub'
require 'json'

class SpoolerServiceForwardsTabSeqTest < AppServicesTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ta9f70',
  'every event-committing write forwards its own (incrementing) tab_seq in the POST body' do
    set_http(HttpJsonRequesterCapturingStub)
    files     = { 'hiker.h' => { 'content' => '' } }
    content   = { 'content' => '', 'truncated' => false }
    summary   = { colour: 'red' }
    laptop_id = 'laptop-abc-123'
    [
      ->(tab_seq) { spooler.kata_file_create('kata-id', files, 'f.txt', laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_file_delete('kata-id', files, 'f.txt', laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_file_rename('kata-id', files, 'a.txt', 'b.txt', laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_file_edit('kata-id', files, laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_ran_tests('kata-id', files, content, content, 0, summary, laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_predicted_right('kata-id', files, content, content, 0, summary, laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_predicted_wrong('kata-id', files, content, content, 0, summary, laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_reverted('kata-id', files, content, content, 0, summary, laptop_id, tab_seq) },
      ->(tab_seq) { spooler.kata_checked_out('kata-id', files, content, content, 0, summary, laptop_id, tab_seq) },
    ].each do |write|
      # A fresh, distinct tab_seq per write (1, 2, 3, ...): asserting each is
      # forwarded verbatim proves the write sends the tab_seq it was given, not a
      # constant, and that a changing value flows through faithfully.
      tab_seq = next_tab_seq
      write.call(tab_seq)
      body = JSON.parse(HttpJsonRequesterCapturingStub.last_request_body)
      assert_equal tab_seq, body['tab_seq'], body.to_json
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ta9f71',
  'a non-event write (SaverService kata_create) does not forward tab_seq (narrow scope)' do
    set_http(HttpJsonRequesterCapturingStub)
    saver.kata_create({ 'version' => 2 })
    body = JSON.parse(HttpJsonRequesterCapturingStub.last_request_body)
    refute body.key?('tab_seq'), body.to_json
  end

end
