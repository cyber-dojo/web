require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  def hex_setup
    set_runner_class('RunnerService')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'smoke test run' do
    in_kata { |kata|
      result = kata.run_tests(run_params(kata))
      assert_equal 'red', result[3]
    }
  end

  # hidden_filenames

  private

  def run_params(kata)
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:flattened(kata.files),
      hidden_filenames:'[]'
    }
  end

  def flattened(files)
    Hash[files.map{|filename,file|
      [filename, file['content']]
    }]
  end

end
