require_relative 'app_controller_test_base'

class FileRenameTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ed', %w(
  file_rename() creates a file-rename event in saver 
  ) do
    old_filename = 'readme.txt'
    new_filename = 'readme2.txt'
    in_kata do
      post_json '/kata/file_rename', {
        id: @id,
        index: @index,
        data: { file_content: @files },
        old_filename: old_filename,
        new_filename: new_filename
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file_rename', event['colour']
      assert_equal old_filename, event['old_filename']
      assert_equal new_filename, event['new_filename']
    end
  end

end
