require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'avatars_exception'

class AvatarsService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'avatars', 5027)
    @http = HttpJson::ResponseUnpacker.new(requester, AvatarsException)
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
