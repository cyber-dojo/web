require_relative 'app_controller_test_base'

class IdRejoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '881C39'
  end

  #- - - - - - - - - - - - - - - -

  test '408',
  'rejoin empty==true' do
    in_kata(:stateless) {
      rejoin
      assert empty?
    }
  end

  #- - - - - - - - - - - - - - - -

  test '409',
  'rejoin empty==false' do
    in_kata(:stateless) {
      as_avatar {
        rejoin
        refute empty?
      }
    }
  end

  #- - - - - - - - - - - - - - - -

  test '40A',
  'rejoin with no id raises' do
    assert_raises {
      get '/id_rejoin/drop_down', params:{}
    }
  end

  private

  def rejoin
    params = { 'format' => 'json', 'id' => kata.id }
    get '/id_rejoin/drop_down', params:params
    assert_response :success
  end

  def empty?
    json['empty']
  end

end
