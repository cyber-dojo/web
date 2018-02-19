require_relative 'http_helper'

class StarterService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - -

  def language_start_points
    http_get(__method__)
  end

  def language_manifest(display_name, exercise_name)
    http_get(__method__, display_name, exercise_name)
  end

  # - - - - - - - - - - - -

  def custom_start_points
    http_get(__method__)
  end

  def custom_manifest(display_name)
    http_get(__method__, display_name)
  end

  def old_manifest(old_name)
    http_get(__method__, old_name)
  end

  private # = = = = = = = =

  include HttpHelper

  def hostname
    'starter'
  end

  def port
    4527
  end

end
