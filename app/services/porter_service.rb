require_relative 'http_helper'

class PorterService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'porter', 4517)
  end

  # - - - - - - - - - - - -

  def sha
    http.get(__method__)
  end

  # - - - - - - - - - - - -

  def port(partial_id)
    http.post(__method__, partial_id)
  end

  private

  attr_reader :http

end
