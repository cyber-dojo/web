require_relative 'app_controller_test_base'

class DojoControllerTest < AppControllerTestBase

  def self.hex_prefix
    '103'
  end

  #- - - - - - - - - - - - - - - -

  test 'BF7',
  'index without id' do
    get '/dojo/index'
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '957',
  'index with old 10-char id' do
    get '/dojo/index', params: { id:'1234512345' }
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test '958',
  'index with new 6-char id' do
    get '/dojo/index', params: { id:'8rb67w' }
    assert_response :success
  end

end
