require_relative 'app_controller_test_base'

class IdJoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '8A08FC'
  end

  #- - - - - - - - - - - - - - - -

  test 'F10',
  'join with id that does exist => !full,avatar_name' do
    in_kata(:stateless) {
      as_avatar {
        refute full?
        assert Avatars.names.include?(avatar.name)
      }
    }
  end

  #- - - - - - - - - - - - - - - -

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

  def assert_join(id)
    join(id)
    avatar_name = json['avatarName']
    refute_nil avatar_name
    avatar_name
  end

  def join(id)
    params = { 'format' => 'json', 'id' => id }
    get '/id_join/drop_down', params:params
    assert_response :success
    json['avatarName']
  end

  def full?
    json['full']
  end

end
