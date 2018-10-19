require_relative 'http_helper'

class SaverService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'saver', 4537)
  end

  # - - - - - - - - - - - -

  def sha
    http.get(__method__)
  end

  # - - - - - - - - - - - -

  def group_exists?(id)
    http.get(__method__, id)
  end

  def group_create(manifest)
    http.post(__method__, manifest)
  end

  def group_manifest(id)
    http.get(__method__, id)
  end

  # - - - - - - - - - - - -

  def group_join(id, indexes)
    http.post(__method__, id, indexes)
  end

  def group_joined(id)
    http.get(__method__, id)
  end

  # - - - - - - - - - - - -

  def kata_exists?(id)
    http.get(__method__, id)
  end

  def kata_create(manifest)
    http.post(__method__, manifest)
  end

  def kata_manifest(id)
    http.get(__method__, id)
  end

  # - - - - - - - - - - - -

  def kata_ran_tests(id, n, files, now, stdout, stderr, status, colour)
    http.post(__method__, id, n, files, now, stdout, stderr, status, colour)
  end

  def kata_tags(id)
    http.get(__method__, id)
  end

  def kata_tag(id, n)
    http.get(__method__, id, n)
  end

  private

  attr_reader :http

end
