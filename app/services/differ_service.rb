require_relative 'http_helper'

class DifferService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'differ', 4567)
  end

  # - - - - - - - - - - - - -

  def sha
    http.get(__method__)
  end

  # - - - - - - - - - - - - -

  def diff(was_files, now_files)
    http.get(__method__, was_files, now_files)
  end

  private

  attr_reader :http

end
