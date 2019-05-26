require_relative '../all'

class AppModelsTestBase < TestBase

  def create_group(t = time_now)
    groups.new_group(starter_manifest(t))
  end

  def create_kata(t = time_now)
    katas.new_kata(starter_manifest(t))
  end

  def starter_manifest(t = time_now)
    em = exercises.manifest('Fizz Buzz')
    manifest = languages.manifest('Ruby, MiniTest')
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']
    manifest['created'] = t
    manifest
  end

end
