# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'runner_exception'

class RunnerService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'runner', 4597, RunnerException)
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
