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

  def create(manifest, files)
    http_post(__method__, manifest, files)
  end

  def manifest(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def id?(id)
    http_get(__method__, id)
  end

  def id_completed(partial_id)
    http_get(__method__, partial_id)
  end

  def id_completions(outer_id)
    http_get(__method__, outer_id)
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
