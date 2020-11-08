# frozen_string_literal: true
require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require 'ostruct'

class HttpJsonTest < AppServicesTestBase

  def self.hex_prefix
    '12D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C6',
  'response.body is not JSON raises' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert_equal 'http response.body is not JSON:sdgdfg', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterNotJsonHashOrArrayStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'42')
    end
  end

  test '2C7',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequesterNotJsonHashOrArrayStub)
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert_equal 'http response.body is not JSON Hash|Array:42', error.message
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
  'differ-service sets keyed:false so json with no key to match path returns the json' do
    set_http(HttpJsonRequesterNoPathKeyStub)
    json = differ.ready?
    assert_equal({"different" => true}, json)
  end

end
