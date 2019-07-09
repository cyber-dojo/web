require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'
require_relative 'runner_exception'

class RunnerService

  def initialize(externals)
    requester = HttpJson::RequestPacker.new(externals.http, 'runner', 4597)
    @http = HttpJson::ResponseUnpacker.new(requester, RunnerException)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    @http.get(__method__, {
      image_name:image_name,
      id:id,
      files:files,
      max_seconds:max_seconds
    })
  end

end
