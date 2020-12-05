# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'json'

class SaverServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body get failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(SaverService::Error) { saver.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body is not JSON', json['message'], error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '442',
  'smoke test ready?' do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '443',
  'smoke test saver methods' do
    dirname = 'katas/34/56/7W'
    filename = dirname + '/' + '7.events.json'
    content = '{"colour":"red"}'

    # run
    assert_equal true, saver.run(saver.dir_make_command(dirname))
    assert_equal true, saver.run(saver.dir_exists_command(dirname))
    assert_equal true, saver.run(saver.file_create_command(filename, content))
    assert_equal true, saver.run(saver.file_append_command(filename, content))
    assert_equal content*2, saver.run(saver.file_read_command(filename))
    assert_raises(SaverService::Error) {
      saver.run(saver.dir_exists_command(42))
    }

    # run_all
    assert_equal [true,content*2], saver.run_all([
      saver.dir_exists_command(dirname),
      saver.file_read_command(filename)
    ])
  end

  private

  def saver
    SaverService.new(self)
  end

end
