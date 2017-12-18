
# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/test_external_helpers.rb

def cd_home
  ENV['CYBER_DOJO_HOME']
end

def cd_env_name(suffix)
  'CYBER_DOJO_' + suffix.upcase
end

# set the defaults
{
  cd_env_name('languages_root') => "#{cd_home}/start_points/languages",
  cd_env_name('exercises_root') => "#{cd_home}/start_points/exercises",
  cd_env_name('custom_root')    => "#{cd_home}/start_points/custom",

  cd_env_name('differ_class')  => 'DifferService',
  cd_env_name('runner_class')  => 'RunnerService',
  cd_env_name('starter_class') => 'StarterService',
  cd_env_name('storer_class')  => 'StorerService',
  cd_env_name('zipper_class')  => 'ZipperService',

  cd_env_name('disk_class')  => 'DiskHost',
  cd_env_name('http_class')  => 'Http',
  cd_env_name('log_class')   => 'LogStdout',
  cd_env_name('shell_class') => 'ShellHost'

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

