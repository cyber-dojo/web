require_relative 'app_services_test_base'
require_relative 'http_json_request_packer_not_json_stub'

class VersionerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '417'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A7',
  'response.body failure is mapped to ExercisesException' do
    set_http(HttpJsonRequestPackerNotJsonStub)
    error = assert_raises(VersionerException) { versioner.sha }
    assert error.message.start_with?('http response.body is not JSON'), error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A8',
  'smoke test ready?()' do
    assert versioner.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3A9',
  'smoke test sha()' do
    assert_sha versioner.sha
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ef0',
  'smoke test dot_env()' do
    dot_env = versioner.dot_env
    keys = %w(
      CYBER_DOJO_PORT
      CYBER_DOJO_CUSTOM
      CYBER_DOJO_EXERCISES
      CYBER_DOJO_LANGUAGES
      CYBER_DOJO_COMMANDER_SHA
      CYBER_DOJO_DIFFER_SHA
      CYBER_DOJO_MAPPER_SHA
      CYBER_DOJO_NGINX_SHA
      CYBER_DOJO_RAGGER_SHA
      CYBER_DOJO_RUNNER_SHA
      CYBER_DOJO_SAVER_SHA
      CYBER_DOJO_STARTER_BASE_SHA
      CYBER_DOJO_WEB_SHA
      CYBER_DOJO_ZIPPER_SHA
    )
    keys.each do |key|
      assert dot_env.has_key?(key)
    end
  end

end
