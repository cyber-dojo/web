
# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/test_external_helpers.rb

def cd_root
  '/usr/src/cyber-dojo'
end

def cd_env_name(suffix)
  'CYBER_DOJO_' + suffix.upcase
end

{
  cd_env_name('disk_class')  => 'HostDisk',
  cd_env_name('git_class')   => 'HostGit',
  cd_env_name('log_class')   => 'StdoutLog',
  cd_env_name('shell_class') => 'HostShell',

  cd_env_name('languages_root') => "#{cd_root}/start_points/languages",
  cd_env_name('exercises_root') => "#{cd_root}/start_points/exercises",
  cd_env_name('custom_root')    => "#{cd_root}/start_points/custom",
  cd_env_name('katas_root')     => "#{cd_root}/katas",

  cd_env_name('storer_class')   => 'HostDiskStorer',
  cd_env_name('runner_class')   => 'DockerTarPipeRunner'

}.each { |key, name|
  ENV[key] = name if ENV[key].nil?
}

# - - - - - - - - - - - - - - - - - - - - - - - -

module Externals # mix-in

  def disk ; @disk  ||= external; end
  def git  ; @git   ||= external; end
  def log  ; @log   ||= external; end
  def shell; @shell ||= external; end

  def env_name(suffix)
    cd_env_name(suffix)
  end

  def env(suffix)
    name = env_name(suffix)
    unslashed(ENV[name] || fail("ENV[#{name}] not set"))
  end

  private

  def external
    key = name_of(caller)
    var = env(key + '_class')
    Object.const_get(var).new(self)
  end

  include NameOfCaller
  include Unslashed

end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# External root-dirs and class-names are set using environment variables.
# This gives tests a way to do Parameterize-From-Above in a way that can
# potentially tunnel through a *deep* stack. For example, I can set an
# environment variable and then run a controller test which issues
# GETs/POSTs, which work their way through the rails stack, eventually
# reaching app/models/dojo.rb (possibly in a different thread)
# where the specificied Double/Mock/Stub class or path takes effect.
#
# The external objects are held using
#    @name ||= ...
# I use ||= partly for optimization and partly for testing
# (where it is sometimes handy that it is the same object)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
