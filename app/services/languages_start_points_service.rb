# frozen_string_literal: true
require_relative 'http_json/requester'
require_relative 'http_json/responder'

class LanguagesStartPointsService

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    name = 'languages-start-points'
    port = ENV['CYBER_DOJO_LANGUAGES_START_POINTS_PORT'].to_i
    requester = HttpJson::Requester.new(externals.http, name, port)
    @http = HttpJson::Responder.new(requester, Error, {keyed:true})
  end

  def ready?
    @http.get(__method__, {})
  end

  def names
    @http.get(__method__, {})
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(name)
    @http.get(__method__, { name:name })
  end

end
