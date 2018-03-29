require_relative 'app_models_test_base'

class KataDefaultsTest < AppModelsTestBase

  def self.hex_prefix
    '4BB621'
  end

  # - - - - - - - - - - - - - - - - - - - -

  test '345', %w( highlight_filenames defaults to empty array ) do
    assert_default 'highlight_filenames', []
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
    manifest = starter.language_manifest('Ruby, MiniTest', 'Fizz_Buzz')
    manifest['id'] = kata_id
    manifest['created'] = time_now
    manifest.delete(name)
    storer.kata_create(manifest)
    assert_equal expected, katas[kata_id].public_send(name)
  end

end
