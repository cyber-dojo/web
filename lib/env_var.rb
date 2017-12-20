
# - - - - - - - - - - - - - - - - - - - - - - - -
# set defauls ENV-vars for all externals
# unit-tests can set/reset these
# see test/test_external_helpers.rb

def cd_env_name(suffix)
  'CYBER_DOJO_' + suffix.upcase
end

# set the defaults
{
  cd_env_name('differ_class')  => 'DifferService',
  cd_env_name('runner_class')  => 'RunnerService',
  cd_env_name('starter_class') => 'StarterService',
  cd_env_name('storer_class')  => 'StorerService',
  cd_env_name('zipper_class')  => 'ZipperService',

  cd_env_name('http_class')  => 'Http',
  cd_env_name('log_class')   => 'LogStdout',

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
    ENV[key] || fail("ENV[#{key}] not set")
  end

end

