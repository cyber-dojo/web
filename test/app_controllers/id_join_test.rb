require_relative 'app_controller_test_base'

class IdJoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '8A0'
  end

  #- - - - - - - - - - - - - - - -

  test 'F11',
  'join succeeds once for each avatar name, then session is full' do
    in_group do |group|
      Avatars.names.each do
        avatar_name = assert_join(group.id)
        refute_nil avatar_name
        refute full?
      end
      avatar_name = join(group.id)
      assert_nil avatar_name
      assert full?
    end
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
