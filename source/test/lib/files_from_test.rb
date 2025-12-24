require_relative 'lib_test_base'
require_relative '../../lib/files_from'

class FilesFromTest < LibTestBase

  def self.hex_prefix
    '640'
  end

  include FilesFrom

  # - - - - - - - - - - - - - - - - -

  test 'DD9', %w(
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

end
