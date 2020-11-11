# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'ostruct'

class HttpJsonTest < AppServicesTestBase

  def self.hex_prefix
    '12D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterNotJson
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'xxxxx')
    end
  end

  test '2C7',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequesterNotJson)
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert_equal 'http response.body is not JSON:xxxxx', error.message
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
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert_equal '"http-stub-threw"', error.message
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
  'JSON Hash with no key to match path returns the json' do
    set_http(HttpJsonRequesterNoPathKeyStub)
    json = differ.ready?
    assert_equal({"different" => true}, json)
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
    json = differ.ready?
    assert_equal([493], json)
  end

end
