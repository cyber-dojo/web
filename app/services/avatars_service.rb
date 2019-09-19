require_relative 'http_json/service'
require_relative 'avatars_exception'

class AvatarsService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'avatars', 5027, AvatarsException)
  end

  def sha
    @http.get(__method__, {})
  end

  def ready?
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

end
