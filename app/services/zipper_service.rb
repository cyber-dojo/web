require_relative 'http_helper'

class ZipperService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'zipper', 4587)
  end

  def sha
    http.get(__method__)
  end

  def zip(kata_id)
    http.get(__method__, kata_id)
  end

  def zip_tag(kata_id, avatar_name, tag)
    http.get(__method__, kata_id, avatar_name, tag)
  end

  private

  attr_reader :http

end
