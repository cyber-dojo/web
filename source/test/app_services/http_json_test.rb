require_relative 'app_services_test_base'
require 'ostruct'

class HttpJsonTest < AppServicesTestBase

  def self.hex_prefix
    '12D'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterNotJsonHashStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'[42]')
    end
  end

  test '2C7',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequesterNotJsonHashStub)
    stdout,stderr = capture_stdout_stderr do
      error = assert_raises(RunnerService::Error) { runner.ready? }
      assert_equal 'body is not JSON Hash', error.message, :error_message
    end
    assert_equal '', stderr, :stderr_is_empty
    refute_equal '', stdout, :stdout_is_not_empty
    expected = {
      'Exception: HttpJson::Responder' => {
        'path' => 'ready?',
        'args' => {},
        'body' => '[42]',
        'message' => 'body is not JSON Hash'
      }
    }
    assert_equal expected, JSON.parse!(stdout), :exception_info_printed_to_stdout
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterExceptionKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'{"exception":"http-stub-threw"}')
    end
  end

  test '2C9',
  'response.body has exception key raises' do
    set_http(HttpJsonRequesterExceptionKeyStub)
    stdout,stderr = capture_stdout_stderr do
      error = assert_raises(RunnerService::Error) { runner.ready? }
      assert_equal 'http-stub-threw', error.message, :error_message
    end
    assert_equal '', stderr, :stderr_is_empty
    refute_equal '', stdout, :stdout_is_not_empty
    expected = {
      'Exception: HttpJson::Responder' => {
        'path' => 'ready?',
        'args' => {},
        'body' => '{"exception":"http-stub-threw"}',
        'message' => 'http-stub-threw'
      }
    }
    assert_equal expected, JSON.parse!(stdout), :exception_info_printed_to_stdout    
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterNoPathKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'{"different":true}')
    end
  end

  test '2C8',
  'JSON Hash with no key to match path raises' do
    set_http(HttpJsonRequesterNoPathKeyStub)
    stdout,stderr = capture_stdout_stderr do    
      error = assert_raises(RunnerService::Error) { runner.ready? }
      assert_equal 'body is missing :path key', error.message, :error_message
    end
    assert_equal '', stderr, :stderr_is_empty
    refute_equal '', stdout, :stdout_is_not_empty
    expected = {
      'Exception: HttpJson::Responder' => {
        'path' => 'ready?',
        'args' => {},
        'body' => '{"different":true}',
        'message' => 'body is missing :path key'
      }
    }
    assert_equal expected, JSON.parse!(stdout), :exception_info_printed_to_stdout        
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterHasPathKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'{"ready?":[493]}')
    end
  end

  test '2CA',
  'JSON Hash with key to match path returns the value for the key' do
    set_http(HttpJsonRequesterHasPathKeyStub)
    json = runner.ready?
    assert_equal([493], json)
  end

end
