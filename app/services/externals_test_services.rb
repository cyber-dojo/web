# frozen_string_literal: true

# make names of service test-double classes available

TEST_SERVICES = File.expand_path('../../test/app_services', __dir__)

def require_test_service(name)
  require "#{TEST_SERVICES}/#{name}"
end

require_test_service 'ragger_exception_raiser'
require_test_service 'ragger_stub'
require_test_service 'runner_stub'
require_test_service 'saver_dummy'
require_test_service 'saver_exception_raiser'
require_test_service 'saver_fake'
