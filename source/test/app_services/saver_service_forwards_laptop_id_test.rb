require_relative 'app_services_test_base'
require_relative 'http_json_requester_capturing_stub'
require 'json'

class SaverServiceForwardsLaptopIdTest < AppServicesTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F4c1A0',
  'every event-committing write forwards its laptop_id argument in the POST body' do
    set_http(HttpJsonRequesterCapturingStub)
    files     = { 'hiker.h' => { 'content' => '' } }
    content   = { 'content' => '', 'truncated' => false }
    summary   = { colour: 'red' }
    laptop_id = 'laptop-abc-123'
    [
      -> { saver.kata_file_create('kata-id', 1, files, 'f.txt', laptop_id) },
      -> { saver.kata_file_delete('kata-id', 1, files, 'f.txt', laptop_id) },
      -> { saver.kata_file_rename('kata-id', 1, files, 'a.txt', 'b.txt', laptop_id) },
      -> { saver.kata_file_edit('kata-id', 1, files, laptop_id) },
      -> { saver.kata_ran_tests('kata-id', 1, files, content, content, 0, summary, laptop_id) },
      -> { saver.kata_predicted_right('kata-id', 1, files, content, content, 0, summary, laptop_id) },
      -> { saver.kata_predicted_wrong('kata-id', 1, files, content, content, 0, summary, laptop_id) },
      -> { saver.kata_reverted('kata-id', 1, files, content, content, 0, summary, laptop_id) },
      -> { saver.kata_checked_out('kata-id', 1, files, content, content, 0, summary, laptop_id) },
    ].each do |write|
      write.call
      body = JSON.parse(HttpJsonRequesterCapturingStub.last_request_body)
      assert_equal laptop_id, body['laptop_id'], body.to_json
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F4c1A1',
  'a non-event write (kata_create) does not forward laptop_id (narrow scope)' do
    set_http(HttpJsonRequesterCapturingStub)
    saver.kata_create({ 'version' => 2 })
    body = JSON.parse(HttpJsonRequesterCapturingStub.last_request_body)
    refute body.key?('laptop_id'), body.to_json
  end

end
