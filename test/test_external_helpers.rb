
module TestExternalHelpers # mix-in

  module_function

  include Externals

  def setup
    @config = {
      'DIFFER'  => ENV['CYBER_DOJO_DIFFER_CLASS'],
      'RUNNER'  => ENV['CYBER_DOJO_RUNNER_CLASS'],
      'STARTER' => ENV['CYBER_DOJO_STARTER_CLASS'],
      'GROUPER' => ENV['CYBER_DOJO_GROUPER_CLASS'],
      'SINGLER' => ENV['CYBER_DOJO_SINGLER_CLASS'],
      'ZIPPER'  => ENV['CYBER_DOJO_ZIPPER_CLASS'],
      'HTTP'    => ENV['CYBER_DOJO_HTTP_CLASS']
    }
  end

  def teardown
    ENV['CYBER_DOJO_DIFFER_CLASS']  = @config['DIFFER']
    ENV['CYBER_DOJO_RUNNER_CLASS']  = @config['RUNNER']
    ENV['CYBER_DOJO_STARTER_CLASS'] = @config['STARTER']
    ENV['CYBER_DOJO_GROUPER_CLASS'] = @config['GROUPER']
    ENV['CYBER_DOJO_SINGLER_CLASS'] = @config['SINGLER']
    ENV['CYBER_DOJO_ZIPPER_CLASS']  = @config['ZIPPER']
    ENV['CYBER_DOJO_HTTP_CLASS']  =   @config['HTTP']
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_differ_class(value)
    set_class('differ', value)
  end

  def set_runner_class(value)
    set_class('runner', value)
  end

  def set_starter_class(value)
    set_class('starter', value)
  end

  def set_class(name, value)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key] = value
  end

end
