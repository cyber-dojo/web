require_relative 'app_services_test_base'

class VersionerServiceTest < AppServicesTestBase

  def self.hex_prefix
    '417'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'Ef0',
  'smoke test versioner' do
    assert versioner.ready?
    assert_sha versioner.sha
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
      CYBER_DOJO_GRAFANA_SHA
      CYBER_DOJO_PROMETHEUS_SHA
    )
    keys.each do |key|
      assert dot_env.has_key?(key)
    end
  end

end
