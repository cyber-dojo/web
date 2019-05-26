require_relative 'app_helpers_test_base'

class LargestTest < AppHelpersTestBase

  def self.hex_prefix
    '5FF'
  end

  include LargestHelper

  test '842',
  'largest when single visible_file' do
    expected = 'x' * 34
    visible_files = {
      'readme.txt' => {
        'content' => expected
      }
    }
    assert_equal expected, largest(visible_files)
  end

  # - - - - - - - - - - - - - - - - - - -

  test '843',
  'largest when more than one visible_file' do
    expected = 'x' * 34
    visible_files = {
      'smaller' => {
        'content' => 'y' * 33,
      },
      'larger.txt' => {
        'content' => expected
      }
    }
    assert_equal expected, largest(visible_files)
  end

end
