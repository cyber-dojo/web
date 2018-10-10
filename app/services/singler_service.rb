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

  def kata_exists?(id)
    http_get(__method__, id)
  end

  def kata_create(manifest, files)
    http_post(__method__, manifest, files)
  end

  def kata_manifest(id)
    http_get(__method__, id)
  end

  # - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
    http_post(__method__, id, n, files, now, stdout, stderr, status, colour)
  end

  def kata_tags(id)
    http_get(__method__, id)
  end

  def kata_tag(id, n)
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
