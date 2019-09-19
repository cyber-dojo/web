# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/service_error'

class RaggerService

  class Error < HttpJson::ServiceError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'ragger', 5537, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def colour(image_name, id, stdout, stderr, status)
    @http.get(__method__, {
      image_name:image_name,
      id:id,
      stdout:stdout,
      stderr:stderr,
      status:status
    })
  end

end
