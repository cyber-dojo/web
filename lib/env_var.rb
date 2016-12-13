
# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/test_external_helpers.rb

def cd_root
  '/app'
end

def cd_env_name(suffix)
  'CYBER_DOJO_' + suffix.upcase
end

{
  # read-only
  cd_env_name('languages_root') => "#{cd_root}/start_points/languages",
  cd_env_name('exercises_root') => "#{cd_root}/start_points/exercises",
  cd_env_name('custom_root')    => "#{cd_root}/start_points/custom",

  # read-write
  cd_env_name('katas_root')     => "#{cd_root}/katas",

  cd_env_name('differ_class') => 'DifferService',
  cd_env_name('storer_class') => 'StorerService',
  cd_env_name('runner_class') => 'RunnerService',

  cd_env_name('disk_class')  => 'HostDisk',
  cd_env_name('log_class')   => 'StdoutLog',
  cd_env_name('shell_class') => 'HostShell'

}.each { |key, name|
  ENV[key] = name if ENV[key].nil?
}

# - - - - - - - - - - - - - - - - - - - - - - - -

class EnvVar

  def name(suffix)
    cd_env_name(suffix)
  end

  def value(suffix)
    key = name(suffix)
    unslashed(ENV[key] || fail("ENV[#{key}] not set"))
  end

  private

  include Unslashed

end

