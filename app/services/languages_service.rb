require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'languages_exception'

class LanguagesService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'languages', 4524)
    @http = HttpJson::ResponseUnpacker.new(requester, LanguagesException)
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
