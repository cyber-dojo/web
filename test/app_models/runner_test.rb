require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'red: expected=42, actual=6*9' do
    ragger.stub_colour('red')
    @params = kata_params
    in_kata do |kata|
      result = kata.run_tests
      assert_equal false, result[0]['timed_out']
      assert_equal 'red', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'amber: expected=42, actual=6*7sss' do
    ragger.stub_colour('amber')
    @params = kata_params
    in_kata do |kata|
      result = kata.run_tests
      assert_equal false, result[0]['timed_out']
      assert_equal 'amber', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '151',
  'green: expected=42, actual=6*7' do
    ragger.stub_colour('green')
    @params = kata_params
    in_kata do |kata|
      result = kata.run_tests
      assert_equal false, result[0]['timed_out']
      assert_equal 'green', colour_of(kata, result[0])
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '152',
  'timed_out: infinite loop' do
    runner.stub_run('','',0,timed_out=true)
    @params = kata_params
    in_kata do |kata|
      result = kata.run_tests
      assert_equal true, result[0]['timed_out']
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # TODO: hidden_filenames
  # TODO: created files
  # TODO: deleted files
  # TODO: changed files

  private

  def colour_of(kata, result)
    stdout = result['stdout']['content']
    stderr = result['stderr']['content']
    status = result['status'].to_i
    ragger.colour(kata.manifest.image_name, kata.id, stdout, stderr, status)
  end

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
