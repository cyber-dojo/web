require_relative 'app_controller_test_base'

class IdJoinControllerTest < AppControllerTestBase

  def self.hex_prefix
    '8A0'
  end

  test 'F10', 'show' do
    get '/id_join/show', as: :html
    assert_response :success
  end

  #- - - - - - - - - - - - - - - -

  test 'F11', %w(
  join new group succeeds 64 times
  and then session is full
  ) do
    in_group do |group|
      Avatars.names.size.times do
        kata = assert_join(group.id)
        refute full?
        assert Avatars.names.include?(kata.avatar_name)
      end
      kata = join(group.id)
      assert_nil kata
      assert full?
    end
  end

  #- - - - - - - - - - - - - - - -

  test 'F12', %w(
  joining a (not-full) existing (schema.version==0) group succeeds
  and kata.schema.version==0
  ) do
    set_saver_class('SaverService')
    kata = assert_join('FxWwrr')
    refute full?
    assert Avatars.names.include?(kata.avatar_name)
    assert_equal 0, kata.schema.version
  end

  #- - - - - - - - - - - - - - - -

  test 'F14',
  'join with id that does not exist results in json with exists=false' do
    join(hex_test_kata_id)
    refute exists?
  end

  #- - - - - - - - - - - - - - - -

  test 'F01', %w( deprecated GET-dropdown is now POST-join ) do
    in_group do |group|
      Avatars.names.size.times do
        kata = assert_old_join(group.id)
        refute full?
        assert Avatars.names.include?(kata.avatar_name)
      end
      kata = old_join(group.id)
      assert_nil kata
      assert full?
    end
  end

  private

  def assert_old_join(gid)
    kid = old_join(gid)
    assert json['exists']
    refute_nil kid
    katas[kid]
  end

  def old_join(gid)
    params = { id:gid }
    get '/id_join/drop_down', params:params, as: :json
    assert_response :success
    json['id']
  end

  def exists?
    json['exists']
  end

  def full?
    json['full']
  end

end
