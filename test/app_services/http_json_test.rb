require_relative '../../app/services/differ_exception'
require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'
require 'ostruct'

class HttpJsonTest < AppServicesTestBase

  def self.hex_prefix
    '12D'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2C6',
  'response.body is not JSON raises' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(DifferException) { differ.sha }
    assert_equal 'http response.body is not JSON:sdgdfg', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequestPackerNotJsonHashStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      return OpenStruct.new(body:'[]')
    end
  end

  test '2C7',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequestPackerNotJsonHashStub)
    error = assert_raises(DifferException) { differ.sha }
    assert_equal 'http response.body is not JSON Hash:[]', error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequestPackerNoPathKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      return OpenStruct.new(body:'{"not_sha":"3234234"}')
    end
  end

  test '2C8',
  'response.body is not JSON Hash raises' do
    set_http(HttpJsonRequestPackerNoPathKeyStub)
    error = assert_raises(DifferException) { differ.sha }
    json = '{"not_sha":"3234234"}'
    assert_equal "http response.body has no key for 'sha':#{json}", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class HttpJsonRequestPackerExceptionKeyStub
    def initialize(_hostname, _port)
    end
    def request(_req)
      return OpenStruct.new(body:'{"exception":"http-stub-threw"}')
    end
  end

  test '2C9',
  'response.body has exception key raises' do
    set_http(HttpJsonRequestPackerExceptionKeyStub)
    error = assert_raises(DifferException) { differ.sha }
    assert_equal '"http-stub-threw"', error.message
  end

end
