require_relative 'app_models_test_base'

class KataDefaultsTest < AppModelsTestBase

  def self.hex_prefix
    '4BB621'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '344', %w( filename_extension defaults to empty string ) do
    assert_default 'filename_extension', ''
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '345', %w( highlight_filenames defaults to empty array ) do
    assert_default 'highlight_filenames', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '346', %w(
  lowlight_filenames defaults to specific 4 files
  when hightlight_filenames is empty ) do
    manifest = starter.language_manifest('C (gcc)', 'assert', 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest.delete('highlight_filenames')
    storer.create_kata(manifest)
    expected = %w( cyber-dojo.sh makefile Makefile unity.license.txt )
    assert_equal expected.sort, katas[kata_id].lowlight_filenames.sort
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '347', %w(
  lowlight_filenames defaults to the complement of highlight_filenames
  when highlight_filenames is not empty ) do
    manifest = starter.language_manifest('C (gcc)', 'assert', 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest['highlight_filenames'] = %w( hiker.c hiker.h hiker.tests.c )
    storer.create_kata(manifest)
    expected = %w( cyber-dojo.sh makefile instructions output )
    assert_equal expected.sort, katas[kata_id].lowlight_filenames.sort
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '348', %w( max_seconds defaults to 10 ) do
    assert_default 'max_seconds', 10
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '349', %w( progress_regexs defaults to empty array ) do
    assert_default 'progress_regexs', []
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '34A', %w( tab_size defaults to 4 ) do
    assert_default 'tab_size', 4
  end

  private # = = = = = = = = = = = = =

  def assert_default(name, expected)
    manifest = starter.language_manifest('Python', 'unittest', 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest.delete(name)
    storer.create_kata(manifest)
    assert_equal expected, katas[kata_id].public_send(name)
  end

end
