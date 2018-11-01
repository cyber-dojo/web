require_relative 'app_controller_test_base'

class IdJoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '8A0'
  end

  #- - - - - - - - - - - - - - - -

  test 'F11',
  'join succeeds once for each avatar name, then dojo is full' do
    in_kata(:stateless) {
      Avatars.names.each do
        avatar_name = assert_join
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
  'join with no id results in json with exists=false' do
    get '/id_join/drop_down', params:{}
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  test 'F13',
  'join with empty string id results in json with exists=false' do
    join('')
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  test 'F14',
  'join with id that does not exist results in json with exists=false' do
    join(hex_test_kata_id)
    refute exists?
  end

  private # = = = = = = = = = = = =

  def exists?
    json['exists']
  end

  def full?
    json['full']
  end

end
