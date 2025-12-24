require_relative 'app_controller_test_base'

class FileDeleteTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '145', %w(
  file_delete() creates a file-delete event in saver 
  ) do
    set_saver_class('SaverService')
    in_kata do
      post '/kata/file_delete', params: {
        'format' => 'js',
        'id' => @id,
        'index' => @index + 1,
        'files' => @files,
        'filename' => 'readme.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-delete', event['event']
    end
  end

end
