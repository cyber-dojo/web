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

  def group_exists?(id)
    http_get(__method__, id)
  end

  def group_create(manifest)
    http_post(__method__, manifest)
  end

  def group_manifest(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def group_join(id, indexes)
    http_post(__method__, id, indexes)
  end

  def group_joined(id)
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
