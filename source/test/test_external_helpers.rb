
module TestExternalHelpers # mix-in

  module_function

  include Externals

  def setup
    @config = {
      'RUNNER'    => ENV['CYBER_DOJO_RUNNER_CLASS'],
      'SAVER'     => ENV['CYBER_DOJO_SAVER_CLASS'],
      'HTTP'      => ENV['CYBER_DOJO_HTTP_CLASS'],
    }
  end

  def teardown
    ENV['CYBER_DOJO_RUNNER_CLASS'] = @config['RUNNER']
    ENV['CYBER_DOJO_SAVER_CLASS']  = @config['SAVER']
    ENV['CYBER_DOJO_HTTP_CLASS']   = @config['HTTP']
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_runner_class(name)
    set_class('runner', name)
  end

  def get_class(name)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key]
  end

  def set_class(name, value)
    key = 'CYBER_DOJO_' + name.upcase + '_CLASS'
    ENV[key] = value
  end

end
