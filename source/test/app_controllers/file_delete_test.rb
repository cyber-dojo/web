require_relative 'app_controller_test_base'

class FileDeleteTest  < AppControllerTestBase

  def self.hex_prefix
    '87C'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # I think the problem with this test is KataController.file_delete
  # is using params_files and that is calling 
  #   data = Rack::Utils.parse_nested_query(params[:data])
  #   files_from(data['file_content'])

  test '145', %w(
  file_delete() creates a file-delete event in saver 
  ) do
    set_saver_class('SaverService')
    in_kata do
      post '/kata/file_delete', params: {
        'format' => 'js',
        'id' => @id,
        'index' => @index + 1,
        'data' => { 'file_content' => @files }, # <<<<
        'filename' => 'readme.txt'
      }
      assert_response :success
      assert_equal 2, kata.events.size
      event = kata.event(1)
      assert_equal 'file-delete', event['event']
    end
  end

end
