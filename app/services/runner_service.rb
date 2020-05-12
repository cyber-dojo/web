# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class RunnerService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    requester = HttpJson::Requester.new(externals.http, 'runner', 4597)
    @http = HttpJson::Responder.new(requester, Error, {keyed:false})
  end

  def ready?
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    args = {
      id:id,
      files:files,
      manifest: {
        image_name:image_name,
        max_seconds:max_seconds
      }
    }
    @http.get(__method__, args)
  end

end
