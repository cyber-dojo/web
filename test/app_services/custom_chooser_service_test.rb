require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/custom_chooser_service'

class CustomChooserServiceTest < AppServicesTestBase

  def self.hex_prefix
    '45A'
  end

  def hex_setup
    set_custom_chooser_class('CustomChooserService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(CustomChooserService::Error) { custom_chooser.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test sha' do
    assert_sha custom_chooser.sha
  end

end
