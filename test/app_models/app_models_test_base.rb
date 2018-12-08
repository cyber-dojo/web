require_relative '../all'

class AppModelsTestBase < TestBase

  def create_group(t = time_now)
    groups.new_group(starter_manifest(t))
  end

  def create_kata(t = time_now)
    katas.new_kata(starter_manifest(t))
  end

  def starter_manifest(t = time_now)
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['created'] = t
    manifest
  end

end
