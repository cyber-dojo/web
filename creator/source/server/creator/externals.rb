require_relative 'external_custom_start_points'
require_relative 'external_exercises_start_points'
require_relative 'external_languages_start_points'
require_relative 'external_http'
require_relative 'external_runner'
require_relative 'external_saver'

module CreatorApp
  class Externals
    def custom_start_points
      @custom_start_points ||=
        ExternalCustomStartPoints.new(custom_http)
    end

    def exercises_start_points
      @exercises_start_points ||=
        ExternalExercisesStartPoints.new(exercises_http)
    end

    def languages_start_points
      @languages_start_points ||=
        ExternalLanguagesStartPoints.new(languages_http)
    end

    def runner
      @runner ||= ExternalRunner.new(runner_http)
    end

    def saver
      @saver ||= ExternalSaver.new(saver_http)
    end

    # - - - - - - - - - - - - - - - - - - - - - - -

    def custom_http
      @custom_http ||= ExternalHttp.new
    end

    def exercises_http
      @exercises_http ||= ExternalHttp.new
    end

    def languages_http
      @languages_http ||= ExternalHttp.new
    end

    def runner_http
      @runner_http ||= ExternalHttp.new
    end

    def saver_http
      @saver_http ||= ExternalHttp.new
    end
  end
end
