require_relative 'http_helper'

class ZipperService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  def zip(kata_id)
    http_get(__method__, kata_id)
  end

  def zip_tag(kata_id, avatar_name, tag)
    http_get(__method__, kata_id, avatar_name, tag)
  end

  private

  include HttpHelper

  def hostname
    'zipper'
  end

  def port
    4587
  end

end
