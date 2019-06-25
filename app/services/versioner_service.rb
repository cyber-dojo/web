require_relative 'http_helper'

class VersionerService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'versioner', 5647)
  end

  def ready?
    @http.get
  end

  def sha
    @http.get
  end

  def dot_env
    @http.get
  end

end
