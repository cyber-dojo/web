require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'
require_relative '../../app/services/mapper_service'

class MapperServiceTest < AppServicesTestBase

  def self.hex_prefix
    'a47'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(MapperService::Error) { mapper.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '8z1',
  'smoke test mapper' do
    assert mapper.ready?
    assert_sha mapper.sha
    refute mapper.mapped?('112233')
    assert_equal '332211', mapper.mapped_id('332211')
  end

end
