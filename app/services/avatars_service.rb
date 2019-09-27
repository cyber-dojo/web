# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/error'

class AvatarsService

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'avatars', 5027, Error)
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
