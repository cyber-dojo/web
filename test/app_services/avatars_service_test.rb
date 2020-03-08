require_relative 'app_services_test_base'
require_relative 'http_json_requester_not_json_stub'
require_relative '../../app/services/avatars_service'

class AvatarsServiceTest < AppServicesTestBase

  def self.hex_prefix
    '6B9'
  end

  def hex_setup
    set_avatars_class('AvatarsService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to exception' do
    set_http(HttpJsonRequesterNotJsonStub)
    error = assert_raises(AvatarsService::Error) { avatars.ready? }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test ready?' do
    assert avatars.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test names' do
    names = avatars.names
    assert_equal 64, names.size
    assert_equal 'alligator', names[0]
    assert_equal 'zebra', names[-1]
  end

end
