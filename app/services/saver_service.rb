require_relative 'http_helper'

class SaverService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'saver', 4537)
  end

  # - - - - - - - - - - - -

  def ready?
    http.get
  end

  def sha
    http.get
  end

  # - - - - - - - - - - - -

  def group_exists?(id)
    http.get(id)
  end

  def group_create(manifest)
    http.post(manifest)
  end

  def group_manifest(id)
    http.get(id)
  end

  # - - - - - - - - - - - -

  def group_join(id, indexes)
    http.post(id, indexes)
  end

  def group_joined(id)
    http.get(id)
  end

  def group_events(id)
    http.get(id)
  end

  # - - - - - - - - - - - -

  def kata_exists?(id)
    http.get(id)
  end

  def kata_create(manifest)
    http.post(manifest)
  end

  def kata_manifest(id)
    http.get(id)
  end

  # - - - - - - - - - - - -

  def kata_ran_tests(id, index, files, now, duration, stdout, stderr, status, colour)
    http.post(id, index, files, now, duration, stdout, stderr, status, colour)
  end

  def kata_events(id)
    http.get(id)
  end

  def kata_event(id, index)
    http.get(id, index)
  end

  private

  attr_reader :http

end
