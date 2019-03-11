require_relative 'http_helper'

class StarterExercisesService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'exercises', 4527)
  end

  # - - - - - - - - - - - -

  def sha
    http.get
  end

  # - - - - - - - - - - - -

  def start_points
    http.get
  end

  def manifest(display_name)
    http.get(display_name)
  end

  private

  attr_reader :http

end
