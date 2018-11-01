require_relative 'app_models_test_base'

class RunnerTest < AppModelsTestBase

  def self.hex_prefix
    'Nn2'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'run with new_files' do
    kata = create_kata([2018,11,1, 9,13,56])
    manifest = kata.manifest
    params = {
      image_name:manifest.image_name,
      max_seconds:manifest.max_seconds,
      file_content:kata.files,
      file_hashes_incoming:kata.files,
      file_hashes_outgoing:kata.files,
      hidden_filenames:'[]'
    }
    #stdout,stderr,status,
    #colour,
    #files,new_files,deleted_files,changed_files
    results = kata.run_tests(params)
  end

  # deleted_files
  # changed_files
  # hidden_filenames
end
