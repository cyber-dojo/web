require_relative 'http_helper'

class StarterService

  def initialize(externals)
    @http = HttpHelper.new(externals, self, 'starter', 4527)
  end

  # - - - - - - - - - - - -

  def sha
    http.get
  end

  # - - - - - - - - - - - -

  def language_start_points
    http.get
  end

  def language_manifest(display_name, exercise_name)
    hash = http.get(display_name, exercise_name)
    manifest = hash['manifest']
    manifest['exercise'] = exercise_name
    manifest['visible_files']['readme.txt'] = hash['exercise']
    manifest
  end

  # - - - - - - - - - - - -

  def custom_start_points
    http.get
  end

  def custom_manifest(display_name)
    http.get(display_name)
  end

  private

  attr_reader :http

end
