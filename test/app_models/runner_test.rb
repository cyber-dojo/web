require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '151',
  'green: expected=42, actual=6*7' do
    runner.stub_run(outcome:'green')
    in_new_kata do |kata|
      result = kata.run_tests(kata_params(kata))
      assert_equal 'green', result[0]['outcome'], :green
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '152',
  'timed_out: infinite loop' do
    runner.stub_run(outcome:'timed_out')
    in_new_kata do |kata|
      result = kata.run_tests(kata_params(kata))
      assert_equal 'timed_out', result[0]['outcome'], :timed_out
    end
  end

  private

  def kata_params(kata)
    {
      id:kata.id,
      image_name:kata.manifest.image_name,
      max_seconds:kata.manifest.max_seconds,
      file_content:plain(kata.events.last.files)
    }
  end

end
