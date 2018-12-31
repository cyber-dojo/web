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

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'smoke test run' do
    set_starter_class('StarterService')
    kata = make_language_kata({ 'display_name' => 'C (gcc), assert' })
    params = run_params(kata)
    # large .c file which truncates in its middle...
    large = "/*" + ('-'* (51*1024)) + "*/"
    params[:file_content]['large.c'] = large
    result = kata.run_tests(params)
    # which means it won't compile
    assert_equal 'amber', result[3]
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
    files.map{|filename,file| [filename, file['content']] }
         .to_h
  end

end
