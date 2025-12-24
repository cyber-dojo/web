require_relative 'app_controller_test_base'

class FileDeleteTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3ed', %w(
  file_rename() creates a file-rename event in saver 
  ) do
    in_kata do
      post '/kata/file_rename', params: {
        'format' => 'js',
        'id' => @id,
        'index' => @index + 1,
        'data' => Rack::Utils.build_nested_query({ 'file_content' => @files }),
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
