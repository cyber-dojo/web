
module TestExternalHelpers # mix-in

  module_function

  def setup
    fail 'setup already called' unless @setup_called.nil?
    @setup_called = true
    @config = {}
    ENV.each { |key, value| @config[key] = value }
    # Ensure remains of previous test interfere with this one.
    # Would be better if test_id (from test_hex_id_helpers.rb) was
    # available here and I set katas_root to
    #   /tmp/cyber-dojo/#{test_id}/katas
    # and the created that dir.
    # Do I need to rm it? Is /tmp state ephemeral?
    set_katas_root('/tmp/cyber-dojo/katas')
    `rm -rf #{get_katas_root} && mkdir -p #{get_katas_root}`
  end

  def teardown
    fail_if_setup_not_called('teardown')
    # set and no previous value -> unset
    (ENV.keys - @config.keys).each { |key| unset(key) }
    # set but has previous value -> restore
    (ENV.keys + @config.keys).each { |key| ENV[key] = @config[key] }
    @setup_called = nil
  end

  # - - - - - - - - - - - - - - - - - - -

  def unset_languages_root; unset_root('languages'); end
  def unset_exercises_root; unset_root('exercises'); end
  def    unset_custom_root; unset_root(   'custom'); end
  def     unset_katas_root; unset_root(    'katas'); end

  def set_languages_root(value); set_root('languages', value); end
  def set_exercises_root(value); set_root('exercises', value); end
  def    set_custom_root(value); set_root(   'custom', value); end
  def     set_katas_root(value); set_root(    'katas', value); end

  def get_languages_root; get_root('languages'); end
  def get_exercises_root; get_root('exercises'); end
  def    get_custom_root; get_root(   'custom'); end
  def     get_katas_root; get_root(    'katas'); end

  # - - - - - - - - - - - - - - - - - - -

  def unset_runner_class; unset_class('runner'); end
  def unset_storer_class; unset_class('storer'); end
  def  unset_shell_class; unset_class( 'shell'); end
  def   unset_disk_class; unset_class(  'disk'); end
  def    unset_git_class; unset_class(   'git'); end
  def    unset_log_class; unset_class(   'log'); end

  def   set_runner_class(value); set_class('runner', value); end
  def   set_storer_class(value); set_class('storer', value); end
  def    set_shell_class(value); set_class( 'shell', value); end
  def     set_disk_class(value); set_class(  'disk', value); end
  def      set_git_class(value); set_class(   'git', value); end
  def      set_log_class(value); set_class(   'log', value); end

  def   get_runner_class; get_class('runner'); end
  def   get_storer_class; get_class('storer'); end
  def    get_shell_class; get_class( 'shell'); end
  def     get_disk_class; get_class(  'disk'); end
  def      get_git_class; get_class(   'git'); end
  def      get_log_class; get_class(   'log'); end

  # - - - - - - - - - - - - - - - - - - -

  def unset(var); ENV.delete(var); end

  def unset_root(name)
    unset(dojo.env_name(name + '_root'))
  end

  def unset_class(name)
    unset(dojo.env_name(name + '_class'))
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_root(key, value)
    fail_if_setup_not_called("set_root(#{key}, #{value})")
    ENV[dojo.env_name(key + '_root')] = value
    `mkdir -p #{value}`
  end

  def set_class(key, value)
    fail_if_setup_not_called("set_class(#{key}, #{value})")
    ENV[dojo.env_name(key + '_class')] = value
  end

  # - - - - - - - - - - - - - - - - - - -

  def get_root(name)
    dojo.env(name + '_root')
  end

  def get_class(name)
    dojo.env(name + '_class')
  end

  def fail_if_setup_not_called(method)
    fail "#{method} NOT executed because setup() not yet called" if @setup_called.nil?
  end

  # - - - - - - - - - - - - - - - - - - -

  def tmp_root
    '/tmp/cyber-dojo'
  end

end
