require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'mapper_exception'

class MapperService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'mapper', 4547)
    @http = HttpJson::ResponseUnpacker.new(requester, MapperException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def mapped?(id6)
    @http.get(__method__, { id6:id6 })
  end

  def mapped_id(partial_id)
    @http.get(__method__, { partial_id:partial_id })
  end

end
