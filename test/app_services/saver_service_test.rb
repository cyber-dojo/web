require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'
require_relative '../../app/services/saver_exception'
require 'json'

class SaverServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
  end

  def hex_setup
    #set_saver_class('SaverService')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A6', 'SaverExceptionRaiser raises SaverException' do
    set_saver_class('SaverExceptionRaiser')
    error = assert_raises(SaverException) { saver.sha }
    assert error.message.start_with?('stub-raiser'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body get failure is mapped to SaverException' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(SaverException) { saver.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '441',
  'smoke test ready?' do
    assert saver.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '442',
  'smoke test sha' do
    assert_sha saver.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '443',
  'smoke test saver methods' do
    assert_saver_service_error { saver.create(42) }
    assert_saver_service_error { saver.exists?(42) }
    assert_saver_service_error { saver.write(4,2) }
    assert_saver_service_error { saver.append(4,2) }
    assert_saver_service_error { saver.read(42) }
    assert_saver_service_error { saver.batch(['read',42]) }
  end

  private

  def assert_saver_service_error(&block)
    error = assert_raises(SaverException) {
      block.call
    }
    json = JSON.parse!(error.message)
    assert_equal 'SaverService', json['class']
  end

end
