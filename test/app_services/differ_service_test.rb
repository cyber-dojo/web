# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'

class DifferServiceTest < AppServicesTestBase

  def self.hex_prefix
    '702'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AB',
  'smoke test ready' do
    assert differ.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3AD',
  'smoke test differ.diff_lines2(id, old_files, new_files)' do
    in_new_kata do |kata|
      stdout = file("Expected: 42\nActual: 54")
      stderr = file('assertion failed')
      status = 0
      kata.ran_tests(kata.id, 1, kata.files, stdout, stderr, status, ran_summary('red'))

      was_files = flattened(kata.events[0].files)
      now_files = flattened(kata.events[1].files)
      actual = differ.diff_lines2(kata.id, was_files, now_files)
      assert actual.is_a?(Array), actual.class.name
      keys = actual[0].keys.sort
      expected = %w( type old_filename new_filename line_counts lines ).sort
      assert_equal expected, keys
    end
  end

  private

  def file(content)
    { 'content' => content,
      'truncated' => false
    }
  end

  def flattened(files)
    files.map{ |filename,file| [filename, file['content']] }.to_h
  end

end
