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
    hostname = ENV['CYBER_DOJO_RUNNER_HOSTNAME']
    if hostname.nil?
      hostname = 'runner'
    end
    port = ENV['CYBER_DOJO_RUNNER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(args)
    @http.get(__method__, args)
  end

  def pull_image(args)
    @http.get(__method__, args)
  end

end
