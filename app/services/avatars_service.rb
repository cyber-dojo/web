# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class AvatarsService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    name = 'avatars'
    port = ENV['CYBER_DOJO_AVATARS_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, name, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

end
