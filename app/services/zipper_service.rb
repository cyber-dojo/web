require_relative 'http_helper'

class ZipperService

  def initialize(externals)
    @externals = externals
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

  def hostname
    ENV['ZIPPER_SERVICE_NAME']
  end

  def port
    ENV['ZIPPER_SERVICE_PORT'].to_i
  end

end
