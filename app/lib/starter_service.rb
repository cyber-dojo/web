require_relative 'http_helper'

class StarterService

  def initialize(parent)
    @parent = parent
  end

  attr_reader :parent

  # - - - - - - - - - - - -

  def languages_choices( current_display_name)
    http_get(__method__, current_display_name)
  end

  def exercises_choices( current_exercise_name)
    http_get(__method__, current_exercise_name)
  end

  def language_manifest(major_name, minor_name, exercise_name)
    http_get(__method__, major_name, minor_name, exercise_name)
  end

  private

  include HttpHelper

  def hostname
    'starter'
  end

  def port
    4527
  end

end
