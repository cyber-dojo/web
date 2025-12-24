require_relative 'app_controller_test_base'

class FileCreateTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '276', %w(
  file_create() creates a file-create event in saver 
  ) do
    set_saver_class('SaverService')
    in_kata do
      post '/kata/file_create', params: {
        'format' => 'js',
        'id' => @id,
        'index' => @index + 1,
        'files' => @files,
        'filename' => 'newfile.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-create', event['event']
    end
  end

end
