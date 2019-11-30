# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/error'

class ExercisesStartPointsService

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'exercises-start-points', 4525, Error)
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
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
