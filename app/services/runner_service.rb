require_relative 'http_helper'

class RunnerService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'runner', 4597)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    http.get(__method__)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    http.post(__method__, image_name, id, files, max_seconds)
  end

  private

  attr_reader :http

end
