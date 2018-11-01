require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'run with new_files' do
    set_runner_class('RunnerService')
    kata = create_kata([2018,11,1, 9,13,56])
    manifest = kata.manifest
    files = kata.files
    incoming = files.clone
    outgoing = files.clone
    outgoing.delete('hiker.rb')
    files.delete('hiker.rb')

    params = {
      runner_choice:manifest.runner_choice,
      image_name:manifest.image_name,
      max_seconds:manifest.max_seconds,
      file_content:files,
      file_hashes_incoming:incoming,
      file_hashes_outgoing:outgoing,
      hidden_filenames:'[]'
    }
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

    kata.run_tests(params)

    assert_equal ['hiker.rb'], http.spied[0][3][:deleted_files].keys
  end

  # deleted_files
  # changed_files
  # hidden_filenames
end
