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
  'red: deliberately initially failing test' do
    kata = gcc_assert_kata
    params = run_params(kata)
    result = kata.run_tests(params)
    assert_equal 'red', result[3]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'amber: file large than max_file_size is truncated' do
    kata = gcc_assert_kata
    params = run_params(kata)
    large = "/*" + ('-'* (51*1024)) + "*/"
    params[:file_content]['large.c'] = large
    result = kata.run_tests(params)
    assert_equal 'amber', result[3]
  end

  # hidden_filenames

  private

  def gcc_assert_kata
    set_starter_class('StarterService')
    make_language_kata({ 'display_name' => 'C (gcc), assert' })
  end

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
