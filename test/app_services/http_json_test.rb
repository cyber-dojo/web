require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/differ_service'
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

  class HttpJsonRequesterNotJsonHashStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'[]')
    end
  end

  test '2C7',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequesterNotJsonHashStub)
    error = assert_raises(DifferService::Error) { differ.ready? }
    assert_equal 'http response.body is not JSON Hash:[]', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequesterNoPathKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      OpenStruct.new(body:'{"not_ready?":true}')
    end
  end

  test '2C8',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequesterNoPathKeyStub)
    error = assert_raises(DifferService::Error) { differ.ready? }
    json = '{"not_ready?":true}'
    assert_equal "http response.body has no key for 'ready?':#{json}", error.message
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

end
