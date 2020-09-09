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
    name = 'runner'
    port = ENV['CYBER_DOJO_RUNNER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, name, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:false})
  end

  def ready?
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(args)
    @http.get(__method__, args)
  end

end
