require_relative 'http_helper'

class MapperService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'mapper', 4547)
  end

  def ready?
    http.get
  end

  def sha
    http.get
  end

  def mapped?(id6)
    http.get(id6)
  end

  def mapped_id(partial_id)
    http.get(partial_id)
  end

  private

  attr_reader :http

end
