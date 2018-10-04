require_relative 'http_helper'

class SinglerService

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

  def ran_tests(id, n, files, now, stdout, stderr, status, colour)
    http_post(__method__, id, n, files, now, stdout, stderr, status, colour)
  end

  def tags(id)
    http_get(__method__, id)
  end

  def tag(id, n)
    http_get(__method__, id, n)
  end

  private

  include HttpHelper

  def hostname
    'singler'
  end

  def port
    4517
  end

end
