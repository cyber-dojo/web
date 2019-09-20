require_relative '../all'

class AppModelsTestBase < TestBase

  class TimeStub
    def initialize(now)
      @now = now
    end
    attr_reader :now
  end

  # - - - - - - - - - - - - - - - - - -

  def kata_params(kata = katas.new_kata(starter_manifest))
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:plain(kata.files),
      hidden_filenames:'[]'
    }
  end

end
