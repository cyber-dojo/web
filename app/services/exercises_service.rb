require_relative 'http_json/service'
require_relative 'exercises_exception'

class ExercisesService

  def initialize(externals)
    @http = HttpJson::service(externals.http, 'exercises', 4525, ExercisesException)
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
