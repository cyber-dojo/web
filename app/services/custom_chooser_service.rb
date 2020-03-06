# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class CustomChooserService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    requester = HttpJson::Requester.new(externals.http, 'custom-chooser', 4536)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def sha
    @http.get(__method__, {})
  end

end
