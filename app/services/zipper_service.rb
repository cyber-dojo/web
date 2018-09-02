require_relative 'http_helper'

class ZipperService

  def initialize(externals)
    @externals = externals
    @hostname = 'zipper'
    @port = 4587
  end

  def sha
    http_get(__method__)
  end

  def zip(kata_id)
    http_get(__method__, kata_id)
  end

  def zip_tag(kata_id, avatar_name, tag)
    http_get(__method__, kata_id, avatar_name, tag)
  end

  private

  include HttpHelper

  attr_reader :hostname, :port

end
