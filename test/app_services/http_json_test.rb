# frozen_string_literal: true
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
    error = assert_raises(RunnerService::Error) { runner.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body is not JSON Hash', json['message'], error.message
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
    error = assert_raises(RunnerService::Error) { runner.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body has embedded exception', json['message'], error.message
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
    error = assert_raises(RunnerService::Error) { json = runner.ready? }
    json = JSON.parse(error.message)
    assert_equal 'body is missing :path key', json['message'], error.message
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
