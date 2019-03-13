require_relative 'http_helper'

class StarterLanguagesService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'languages', 4525)
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
