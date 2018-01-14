require_relative 'app_models_test_base'

class AvatarsTest < AppModelsTestBase

  def self.hex_prefix
    'B6FE29'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'there are 64 avatar names' do
    assert_equal 64, Avatars.names.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '12F',
  'avatars.each is [] when empty' do
    in_kata {
      assert_equal [], kata.avatars.to_a
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F79',
  'avatars returns all avatars started in the kata' do
    in_kata {
      assert_equal [], kata.avatars.names.sort
      as(:cheetah) {}
      assert_equal ['cheetah'], kata.avatars.names.sort
      as(:lion) {}
      assert_equal ['cheetah', 'lion'], kata.avatars.names.sort
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '638', %w(
  avatars[invalid-name] is not nil
  because validity is check on use not on creation ) do
    in_kata {
      refute_nil kata.avatars[nil], 'nil'
      refute_nil kata.avatars['mobile-phone'], 'invalid'
      refute_nil kata.avatars['cheetah'], 'unstarted'
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74D',
  'avatars[panda] is the panda when the panda has started' do
    in_kata {
      as(:panda) {}
      assert_equal ['panda'], kata.avatars.names
      assert_equal 'panda', katas[kata.id].avatars['panda'].name
    }
  end

end
