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
  'run with deleted_files' do
    params = create_params
    params[:file_hashes_outgoing].delete('hiker.rb')
    params[:file_content].delete('hiker.rb')
    spy_http
    kata.run_tests(params)
    assert_equal ['hiker.rb'], http_args[:deleted_files].keys
  end

  # - - - - - - - - - - - - - - - - - -

  test '150',
  'run with new_files' do
    params = create_params
    params[:file_hashes_outgoing]['new-file.txt'] = 'hello world'
    params[:file_content]['new-file.txt'] = 'hello world'
    spy_http
    kata.run_tests(params)
    assert_equal ['new-file.txt'], http_args[:new_files].keys
  end

  # - - - - - - - - - - - - - - - - - -

  test '151',
  'run with changed_files' do
    params = create_params
    params[:file_hashes_outgoing]['cyber-dojo.sh'] = 'changed...'
    params[:file_content]['cyber-dojo.sh'] = 'changed...'
    spy_http
    kata.run_tests(params)
    assert_equal ['cyber-dojo.sh'], http_args[:changed_files].keys
  end

  # hidden_filenames

  private

  def create_params
    kata = create_kata
    manifest = kata.manifest
    files = kata.files
    {
      runner_choice:manifest.runner_choice,
      image_name:manifest.image_name,
      max_seconds:manifest.max_seconds,
      file_content:files.clone,
      file_hashes_incoming:files.clone,
      file_hashes_outgoing:files.clone,
      hidden_filenames:'[]'
    }
  end

  def spy_http
    @http = nil
    set_class('http', 'HttpSpy')
    http.stub({
      'stdout' => '',
      'stderr' => '',
      'status' => 0,
      'colour' => 'red',
      'new_files' => {},
      'deleted_files' => {},
      'changed_files' => {}
    })
  end

  def http_args
    http.spied[0][3]
  end

end
