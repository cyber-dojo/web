require_relative 'app_controller_test_base'

class FileCreateTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # I think the problem with this test is KataController.file_create
  # is using params_files and that is calling 
  #   data = Rack::Utils.parse_nested_query(params[:data])
  #   files_from(data['file_content'])

  test '276', %w(
  file_create() creates a file-create event in saver 
  ) do
    set_saver_class('SaverService')
    in_kata do
      post '/kata/file_create', params: {
        'format' => 'js',
        'id' => @id,
        'index' => @index + 1,
        'data' => { 'file_content' => @files },
        'filename' => 'newfile.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-create', event['event']
    end
  end

end
