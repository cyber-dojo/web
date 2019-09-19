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

  def kata_params(kata)
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:plain(kata.files),
      hidden_filenames:'[]'
    }
  end

end
