require_relative 'app_controller_test_base'

class FileEditTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '1cd', %w(
  file_edit() creates a file-edit event in saver 
  ) do
    edited_filename = 'readme.txt'
    in_kata do
      @files[edited_filename] += 'Hello world'
      post_json '/kata/file_edit', {
        'id' => @id,
        'index' => @index,
        'data' => { 'file_content' => @files }
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-edit', event['event']
      assert_equal edited_filename, event['filename']
    end
  end

end
