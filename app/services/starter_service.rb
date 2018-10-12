require_relative 'http_helper'

class StarterService

  def initialize(externals)
    @externals = externals
    @hostname = 'starter'
    @port = 4527
  end

  # - - - - - - - - - - - -

  def sha
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def language_start_points
    http_get(__method__)
  end

  def language_manifest(display_name, exercise_name)
    hash = http_get(__method__, display_name, exercise_name)
    manifest = hash['manifest']
    manifest['exercise'] = exercise_name
    manifest['starter_files']['readme.txt'] = hash['exercise']
    manifest
  end

  # - - - - - - - - - - - -

  def custom_start_points
    http_get(__method__)
  end

  def custom_manifest(display_name)
    http_get(__method__, display_name)
  end

  private # = = = = = = = =

  include HttpHelper

  attr_reader :hostname, :port

end
