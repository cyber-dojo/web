# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/error'

class RunnerService

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'runner', 4597, Error)
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
