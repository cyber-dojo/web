
# - - - - - - - - - - - - - - - - - - - - - - - -
# Sets default ENV-vars for all externals.
# Tests can set/reset these.
# See test/test_external_helpers.rb

def cd_env_name(suffix)
  'CYBER_DOJO_' + suffix.upcase
end

{
  cd_env_name('differ_class')  => 'DifferService',
  cd_env_name('runner_class')  => 'RunnerService',
  cd_env_name('starter_class') => 'StarterService',
  cd_env_name('storer_class')  => 'StorerService',
  cd_env_name('zipper_class')  => 'ZipperService',

  cd_env_name('http_class') => 'Http',

}.each { |key, name|
  if ENV[key].nil?
    ENV[key] = name
  end
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

