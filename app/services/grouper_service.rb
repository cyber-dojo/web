require_relative 'http_helper'

class GrouperService

  def initialize(externals)
    @externals = externals
    @hostname = 'grouper'
    @port = 4537
  end

  # - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def create(manifest)
    http_post(__method__, manifest)
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

  def join(id)
    http_post(__method__, id)
  end

  def joined(id)
    http_get(__method__, id)
  end

  private

  include HttpHelper

  attr_reader :hostname, :port

end
