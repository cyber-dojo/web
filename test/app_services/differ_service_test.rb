require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/differ_service'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(DifferService::Error) { differ.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AA',
  'smoke test sha' do
    assert_sha differ.sha
  end

  test '3AB',
  'smoke test ready' do
    assert differ.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AC',
  'smoke test differ.diff(..., was_tag=0, now_tag=1)' do
    in_new_kata do |kata|
      args = []
      args << (index = 1)
      args << kata.files
      args << (now = [2016,12,8, 8,3,23,654])
      args << (duration = 1.6754)
      args << (stdout = file("Expected: 42\nActual: 54"))
      args << (stderr = file('assertion failed'))
      args << (status = 0)
      args << (colour = 'red')
      kata.ran_tests(*args)

      was_files = flattened(kata.events[0].files)
      now_files = flattened(kata.events[1].files)
      actual = differ.diff(kata.id, was_files, now_files)

      filename = 'hiker.rb'
      refute_nil actual[filename]
      expected = [
        { "line"=>"",           "type"=>"same", "number"=>1 },
        { "line"=>"def answer", "type"=>"same", "number"=>2 },
        { "line"=>"  6 * 9",    "type"=>"same", "number"=>3 },
        { "line"=>"end",        "type"=>"same", "number"=>4 }
      ]
      assert_equal(expected, actual[filename])
    end
  end

  private

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

  def flattened(files)
    files.map{ |filename,file| [filename, file['content']] }
         .to_h
  end

end
