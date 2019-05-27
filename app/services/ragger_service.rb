require_relative 'http_helper'

class RaggerService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'ragger', 5537)
  end

  def sha
    http.get
  end

  def colour(image_name, id, stdout, stderr, status)
    http.get(image_name, id, stdout, stderr, status)
  end

  private

  attr_reader :http

end
