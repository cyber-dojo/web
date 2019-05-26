require_relative 'app_services_test_base'
require 'json'

class SaverServiceTest < AppServicesTestBase

  def self.hex_prefix
    'D2w'
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

  test '444',
  'smoke test saver methods' do
    assert_saver_service_error { saver.group_exists?(1) }
    assert_saver_service_error { saver.group_create(1) }
    assert_saver_service_error { saver.group_manifest(1) }
    assert_saver_service_error { saver.group_join(1,2) }
    assert_saver_service_error { saver.group_joined(1) }
    assert_saver_service_error { saver.group_events(1) }

    assert_saver_service_error { saver.kata_exists?(1) }
    assert_saver_service_error { saver.kata_create(1) }
    assert_saver_service_error { saver.kata_manifest(1) }
    assert_saver_service_error { saver.kata_ran_tests(1,2,3,4,5,6,7,8,9) }
    assert_saver_service_error { saver.kata_events(1) }
    assert_saver_service_error { saver.kata_event(1,2) }
  end

  private

  def assert_saver_service_error(&block)
    error = assert_raises(ServiceError) {
      block.call
    }
    json = JSON.parse!(error.message)
    assert_equal 'SaverService', json['class']
  end

end
