require_relative 'http_json_hash/service'

class ExternalDashboard
  def initialize(http)
    @http = HttpJsonHash.service(self.class.name, http, 'server', 4527)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def alive?
    @http.get(__method__, {})
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end
end
