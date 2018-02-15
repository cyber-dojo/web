require_relative 'http_helper'

class StarterService

  def initialize(externals)
    @externals = externals
  end

  # - - - - - - - - - - - -

  def languages_exercises_start_points
    http_get(__method__)
  end

  def language_exercise_manifest(display_name, exercise_name)
    http_get(__method__, display_name, exercise_name)
  end

  # - - - - - - - - - - - -

  def custom_choices
    http_get(__method__)
  end

  def languages_choices
    http_get(__method__)
  end

  def exercises_choices
    http_get(__method__)
  end

  # - - - - - - - - - - - -

  def custom_manifest(major_name, minor_name)
    http_get(__method__, major_name, minor_name)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    http_get(__method__, major_name, minor_name, exercise_name)
  end

  def manifest(old_name)
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
