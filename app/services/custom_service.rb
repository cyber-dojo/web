require_relative 'http_json/service'
require_relative 'custom_exception'

class CustomService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'custom', 4526, CustomException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
