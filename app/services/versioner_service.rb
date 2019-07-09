require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'versioner_exception'

class VersionerService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'versioner', 5647)
    @http = HttpJson::ResponseUnpacker.new(requester, VersionerException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def dot_env
    @http.get(__method__, {})
  end

end
