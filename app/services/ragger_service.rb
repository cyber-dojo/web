# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class RaggerService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    requester = HttpJson::Requester.new(externals.http, 'ragger', 5537)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def colour(image_name, id, stdout, stderr, status)
    @http.get(__method__, {
      image_name:image_name,
      id:id,
      stdout:stdout,
      stderr:stderr,
      status:status
    })
  end

end
