require_relative '../all'

class AppModelsTestBase < TestBase

  class TimeStub
    def initialize(now)
      @now = now
    end
    attr_reader :now
  end

  # - - - - - - - - - - - - - - - - - -
  
  def create_group
    groups.new_group(starter_manifest)
  end

  def create_kata
    katas.new_kata(starter_manifest)
  end

  def starter_manifest
    em = exercises.manifest('Fizz Buzz')
    manifest = languages.manifest('Ruby, MiniTest')
    manifest['visible_files'].merge!(em['visible_files'])
    manifest['exercise'] = em['display_name']
    manifest['created'] = time.now
    manifest
  end

  def kata_params(kata = create_kata)
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:plain(kata.files),
      hidden_filenames:'[]'
    }
  end

end
