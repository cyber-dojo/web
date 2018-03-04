require_relative 'app_controller_test_base'

class DojoControllerTest < AppControllerTestBase

  def self.hex_prefix
    '1032DA'
  end

  #- - - - - - - - - - - - - - - -

  test 'BF7',
  'index without id' do
    get '/dojo/index'
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '957',
  'index with id' do
    get '/dojo/index', params: { id:'1234512345' }
    assert_response :success
  end

end
