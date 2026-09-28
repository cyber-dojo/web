require_relative 'creator_test_base'
require_source 'scoped_env_var_helper'
require_source 'external_custom_start_points'
require_source 'external_exercises_start_points'
require_source 'external_languages_start_points'
require_source 'external_runner'
require_source 'external_saver'

class ExternalHostnameTest < CreatorTestBase

  include ScopedEnvVarHelper

  # - - - - - - - - - - - - - - - - -

  qtest Qs8w10: %w[
    |ExternalCustomStartPoints
    |has hostname set from env-var
    |CYBER_DOJO_CUSTOM_START_POINTS_HOSTNAME
    |as required by nginx
  ] do
    name = 'CYBER_DOJO_CUSTOM_START_POINTS_HOSTNAME'
    value = 'custom-start-points.cyber-dojo.eu-central-1'
    scoped_env_var(name, value) do
      lsp = ExternalCustomStartPoints.new(nil)
      assert_equal value, lsp.http.requester.hostname
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Qs8w11: %w[
    |ExternalExercisesStartPoints
    |has hostname set from env-var
    |CYBER_DOJO_EXERCISES_START_POINTS_HOSTNAME
    |as required by nginx
  ] do
    name = 'CYBER_DOJO_EXERCISES_START_POINTS_HOSTNAME'
    value = 'exercises-start-points.cyber-dojo.eu-central-1'
    scoped_env_var(name, value) do
      lsp = ExternalExercisesStartPoints.new(nil)
      assert_equal value, lsp.http.requester.hostname
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Qs8w12: %w[
    |ExternalLanguagesStartPoints
    |has hostname set from env-var
    |CYBER_DOJO_LANGUAGES_START_POINTS_HOSTNAME
    |as required by nginx
  ] do
    name = 'CYBER_DOJO_LANGUAGES_START_POINTS_HOSTNAME'
    value = 'languages-start-points.cyber-dojo.eu-central-1'
    scoped_env_var(name, value) do
      lsp = ExternalLanguagesStartPoints.new(nil)
      assert_equal value, lsp.http.requester.hostname
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Qs8w13: %w[
    |ExternalRunner
    |has hostname set from env-var
    |CYBER_DOJO_RUNNER_HOSTNAME
    |as required by nginx
  ] do
    name = 'CYBER_DOJO_RUNNER_HOSTNAME'
    value = 'runner.cyber-dojo.eu-central-1'
    scoped_env_var(name, value) do
      lsp = ExternalRunner.new(nil)
      assert_equal value, lsp.http.requester.hostname
    end
  end

  # - - - - - - - - - - - - - - - - -

  qtest Qs8w14: %w[
    |ExternalSaver
    |has hostname set from env-var
    |CYBER_DOJO_SAVER_HOSTNAME
    |as required by nginx
  ] do
    name = 'CYBER_DOJO_SAVER_HOSTNAME'
    value = 'saver.cyber-dojo.eu-central-1'
    scoped_env_var(name, value) do
      lsp = ExternalSaver.new(nil)
      assert_equal value, lsp.http.requester.hostname
    end
  end
end
