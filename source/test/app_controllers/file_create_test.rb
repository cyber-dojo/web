require_relative 'app_controller_test_base'

class FileCreateTest  < AppControllerTestBase

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '87C276', %w(
  | file_create() creates a file-create event in saver 
  ) do
    created_filename = 'newfile.txt'
    in_kata do
      post_json '/kata/file_create', {
        id: @id,
        index: @index,
        data: { file_content: @files },
        filename: created_filename
      }
      assert last_response.ok?
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file_create', event['colour']
      assert_equal created_filename, event['filename']
    end
  end

end
