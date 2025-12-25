require_relative 'app_controller_test_base'

class FileCreateTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  file_create() creates a file-create event in saver 
  ) do
    in_kata do
      post_json '/kata/file_create', {
        'id' => @id,
        'index' => @index + 1,
        'data' => { 'file_content' => @files },
        'filename' => 'newfile.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-create', event['event']
      assert_equal 'newfile.txt', event['filename']
    end
  end

end
