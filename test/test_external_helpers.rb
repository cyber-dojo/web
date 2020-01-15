
module TestExternalHelpers # mix-in

  module_function

  include Externals

  def setup
    @config = {
      'AVATARS'   => ENV['CYBER_DOJO_AVATARS_CLASS'],
      'EXERCISES' => ENV['CYBER_DOJO_EXERCISES_CLASS'],
      'LANGUAGES' => ENV['CYBER_DOJO_LANGUAGES_CLASS'],
      'DIFFER'    => ENV['CYBER_DOJO_DIFFER_CLASS'],
      'RUNNER'    => ENV['CYBER_DOJO_RUNNER_CLASS'],
      'SAVER'     => ENV['CYBER_DOJO_SAVER_CLASS'],
      'ZIPPER'    => ENV['CYBER_DOJO_ZIPPER_CLASS'],
      'HTTP'      => ENV['CYBER_DOJO_HTTP_CLASS'],

      'CUSTOM_START_POINTS'    => ENV['CYBER_DOJO_CUSTOM_START_POINTS_CLASS'],
      'EXERCISES_START_POINTS' => ENV['CYBER_DOJO_EXERCISES_START_POINTS_CLASS'],
      'LANGUAGES_START_POINTS' => ENV['CYBER_DOJO_LANGUAGES_START_POINTS_CLASS']
    }
  end

  def teardown
    ENV['CYBER_DOJO_AVATARS_CLASS']   = @config['AVATARS']
    ENV['CYBER_DOJO_EXERCISES_CLASS'] = @config['EXERCISES']
    ENV['CYBER_DOJO_LANGUAGES_CLASS'] = @config['LANGUAGES']
    ENV['CYBER_DOJO_DIFFER_CLASS']    = @config['DIFFER']
    ENV['CYBER_DOJO_RUNNER_CLASS']    = @config['RUNNER']
    ENV['CYBER_DOJO_SAVER_CLASS']     = @config['SAVER']
    ENV['CYBER_DOJO_ZIPPER_CLASS']    = @config['ZIPPER']
    ENV['CYBER_DOJO_HTTP_CLASS']      = @config['HTTP']

    ENV['CYBER_DOJO_CUSTOM_START_POINTS_CLASS']    = @config['CUSTOM_START_POINTS']
    ENV['CYBER_DOJO_EXERCISES_START_POINTS_CLASS'] = @config['EXERCISES_START_POINTS']
    ENV['CYBER_DOJO_LANGUAGES_START_POINTS_CLASS'] = @config['LANGUAGES_START_POINTS']
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_avatars_class(name)
    set_class('avatars', name)
  end

  def set_custom_start_points_class(name)
    set_class('custom_start_points', name)
  end

  def set_exercises_start_points_class(name)
    set_class('exercises_start_points', name)
  end

  def set_languages_start_points_class(name)
    set_class('languages_start_points', name)
  end

  def set_differ_class(name)
    set_class('differ', name)
  end

  def set_runner_class(name)
    set_class('runner', name)
  end

  def set_saver_class(name)
    set_class('saver', name)
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_class(name, value)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key] = value
  end

end
