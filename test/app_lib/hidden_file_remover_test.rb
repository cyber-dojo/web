require_relative 'app_lib_test_base'

class HiddenFileRemoverTest < AppLibTestBase

  def self.hex_prefix
    '33199'
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '52A',
  'use hidden_filename ending in / to remove all new-filenames in that dir' do
    new_files = {
      'alpha.txt' => 'Hello',
      'objs/hiker.d' => '...',
      'objs/hiker_test.d' => '...',
      'lib/blah.txt' => '...'
    }
    hidden_filenames = [
      'objs/'
    ]
    remove_hidden_files(new_files, hidden_filenames)
    expected = [ 'alpha.txt', 'lib/blah.txt' ]
    assert_equal(expected.sort, new_files.keys.sort)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '52B',
  'use hidden_filename starting in * to removes all new-filenames matching the extension' do
    new_files = {
      'alpha.feature.cs' => 'Hello',
      'beta.feature.cs' => 'Welcome',
      'alpha.cs' => 'Tweedledee',
      'beta.cs' => 'Tweedledum',
      'lib/blah.txt' => '...'
    }
    hidden_filenames = [
      '.*\.feature\.cs'
    ]
    remove_hidden_files(new_files, hidden_filenames)
    expected = [ 'alpha.cs', 'beta.cs', 'lib/blah.txt' ]
    assert_equal(expected.sort, new_files.keys.sort)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '52C',
  'use hidden_filename not ending in / to remove any new-filename matching exactly' do
    new_files = {
      'alpha.txt' => 'Hello',
      'alphaDtxt' => 'Close',
      'beta.txt' => 'Goodbye',
      'objs/hiker.d' => '....',
      'objs/hiker_test.d' => '....'
    }
    hidden_filenames = [
      'alpha\.txt'
    ]
    remove_hidden_files(new_files, hidden_filenames)
    expected = [
      'alphaDtxt',
      'beta.txt',
      'objs/hiker.d',
      'objs/hiker_test.d'
    ]
    assert_equal(expected.sort, new_files.keys.sort)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '52D',
  'hidden_filenames is empty array leaves new-files unchanged' do
    new_files = {
      'alpha.txt' => '...',
      'beta.txt' => '...'
    }
    hidden_filenames = []
    remove_hidden_files(new_files, hidden_filenames)
    expected = [ 'alpha.txt', 'beta.txt' ]
    assert_equal(expected.sort, new_files.keys.sort)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  test '52E',
  'hidden_filenames real example from ruby-minitest' do
    new_files = {
      'coverage.txt' => '...',
      'coverage/.resultset.json' => '...',
      'coverage/.last_run.json' => '...'
    }
    hidden_filenames = [
      "coverage/\.resultset\.json",
      "coverage/\.last_run\.json"
    ]
    remove_hidden_files(new_files, hidden_filenames)
    expected = [ 'coverage.txt' ]
    assert_equal(expected.sort, new_files.keys.sort)
  end

  #- - - - - - - - - - - - - - - - - - - - - -

  include HiddenFileRemover

end
