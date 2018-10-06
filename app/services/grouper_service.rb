require_relative 'http_helper'

class GrouperService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def exists?(id)
    http_get(__method__, id)
  end

  def create(manifest, files)
    http_post(__method__, manifest, files)
  end

  def manifest(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def join(id, indexes)
    http_post(__method__, id, indexes)
  end

  def joined(id)
    http_get(__method__, id)
  end

  private

  include HttpHelper

  def hostname
    'grouper'
  end

  def port
    4537
  end

end
