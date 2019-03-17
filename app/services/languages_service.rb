require_relative 'http_helper'

class LanguagesService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'languages', 4525)
  end

  def sha
    http.get
  end

  def names
    http.get
  end

  def manifest(name)
    http.get(name)
  end

  private

  attr_reader :http

end
