require_relative 'lib_test_base'
require_relative '../../lib/files_from'

class FilesFromTest < LibTestBase

  def self.hex_prefix
    '640'
  end

  include FilesFrom

  # - - - - - - - - - - - - - - - - -

  test 'DD8', %w(
  files_from removes output
  ) do
    file_content = {
      'wibble.txt' => 'Hello world',
      'output' => 'wibble'
    }
    files = files_from(file_content)
    expected = { 'wibble.txt' => { 'content' => 'Hello world' }}
    assert_equal expected, files
  end

  # - - - - - - - - - - - - - - - - -

  test 'DD9', %w(
  files_from truncates to 50K content
  ) do
    biggest = "X" * (50 * 1024)
    file_content = { 'wibble.txt' => biggest + "X" }
    files = files_from(file_content)
    expected = { 'wibble.txt' => { 'content' => biggest }}
    assert_equal expected, files
  end

end
