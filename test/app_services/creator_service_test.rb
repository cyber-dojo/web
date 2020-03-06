require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/creator_service'

class CreatorServiceTest < AppServicesTestBase

  def self.hex_prefix
    '45B'
  end

  def hex_setup
    set_creator_class('CreatorService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(CreatorService::Error) { creator.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test sha' do
    assert_sha creator.sha
  end

end
