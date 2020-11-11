# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class DifferService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    hostname = 'differ'
    port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, hostname, port)
    @http = HttpJson::Responder.new(requester, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def diff_lines(id, was_index, now_index)
    @http.get(__method__, {
      id:id,
      was_index:was_index,
      now_index:now_index
    })
  end

  # diff_summary() is called directly from .js in a $.getJSON() request
  # which nginx reroutes to the differ-service.

end
