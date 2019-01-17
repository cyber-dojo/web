require_relative 'app_controller_test_base'

class IdJoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '8A0'
  end

  #- - - - - - - - - - - - - - - -

  test 'F11',
  'join succeeds once for each avatar name, then session is full' do
    in_group do |group|
      Avatars.names.size.times do
        kata = assert_join(group.id)
        assert Avatars.names.include?(kata.avatar_name)
        refute full?
      end
      kata = join(group.id)
      assert_nil kata
      assert full?
    end
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
