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

=begin

  test 'F11',
  'join succeeds once for each avatar name, then dojo is full' do
    in_kata(:stateless) {
      Avatars.names.each do
        avatar_name = assert_join(kata.id)
        refute_nil avatar_name
        assert Avatars.names.include?(avatar_name)
        refute full?
      end
      assert_equal Avatars.names, kata.avatars.names.sort
      avatar_name = join(kata.id)
      assert_nil avatar_name
      assert full?
    }
  end

  #- - - - - - - - - - - - - - - -

  test 'F12',
  'join with no id raises' do
    assert_raises {
      get '/id_join/drop_down', params:{}
    }
  end

  #- - - - - - - - - - - - - - - -

  test 'F13',
  'join with empty string id results in json with exists=false' do
    join('')
    assert_equal false, json['exists']
  end

  #- - - - - - - - - - - - - - - -

  test 'F14',
  'join with id that does not exist results in json with exists=false' do
    join('ab00ab11ab')
    assert_equal false, json['exists']
  end

  private # = = = = = = = = = = = =

  def full?
    json['full']
  end

=end
