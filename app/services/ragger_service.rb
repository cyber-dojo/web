require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'ragger_exception'

class RaggerService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'ragger', 5537)
    @http = HttpJson::ResponseUnpacker.new(requester, RaggerException)
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
