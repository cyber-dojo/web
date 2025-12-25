require_relative 'app_controller_test_base'

class FileRenameTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ed', %w(
  file_rename() creates a file-rename event in saver 
  ) do
    in_kata do
      post_json '/kata/file_rename', {
        'id' => @id,
        'index' => @index + 1,
        'data' => { 'file_content' => @files },
        'old_filename' => 'readme.txt',
        'new_filename' => 'readme2.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-rename', event['event']
      assert_equal 'readme.txt', event['old_filename']
      assert_equal 'readme2.txt', event['new_filename']
    end
  end

end
