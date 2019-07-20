require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'differ_exception'

class DifferService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'differ', 4567)
    @http = HttpJson::ResponseUnpacker.new(requester, DifferException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def diff(id, old_files, new_files)
    @http.get(__method__, {
      id:id,
      old_files:old_files,
      new_files:new_files
    })
  end

end
