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
      assert exists?
      assert empty?
    }
  end

  #- - - - - - - - - - - - - - - -

  test '409',
  'rejoin empty==false' do
    in_kata(:stateless) {
      as_avatar {
        rejoin
        assert exists?
        refute empty?
      }
    }
  end

  #- - - - - - - - - - - - - - - -

  test '40A',
  'rejoin with invalid id => exists=false' do
    rejoin(hex_test_kata_id)
    refute exists?
    assert_nil empty?
  end

  #- - - - - - - - - - - - - - - -

  test '40B',
  'rejoin with no id results in json with exists=false' do
    get '/id_rejoin/drop_down', params:{}
    refute exists?
  end

  private

  def rejoin(id = kata.id)
    params = { 'format' => 'json', 'id' => id }
    get '/id_rejoin/drop_down', params:params
    assert_response :success
  end

  def exists?
    json['exists']
  end

  def empty?
    json['empty']
  end

end
