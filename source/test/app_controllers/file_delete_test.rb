require_relative 'app_controller_test_base'

class FileDeleteTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '145', %w(
  file_delete() creates a file-delete event in saver 
  ) do
    in_kata do
      post_json '/kata/file_delete', {
        'id' => @id,
        'index' => @index + 1,
        'data' => { 'file_content' => @files },
        'filename' => 'readme.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-delete', event['event']
      assert_equal 'readme.txt', event['filename']
    end
  end

end
