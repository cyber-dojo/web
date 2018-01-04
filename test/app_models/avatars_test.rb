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
    kata = make_language_kata
    assert_equal [], kata.avatars.to_a
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'F79',
  'avatars returns all avatars started in the kata' do
    kata = make_language_kata
    assert_equal [], kata.avatars.names.sort
    kata.start_avatar([cheetah])
    assert_equal [cheetah], kata.avatars.names.sort
    kata.start_avatar([lion])
    assert_equal [cheetah, lion], kata.avatars.names.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '555',
  'avatars.map works' do
    kata = make_language_kata
    kata.start_avatar([cheetah])
    kata.start_avatar([lion])
    assert_equal [cheetah, lion], kata.avatars.names.sort
    assert_equal 2, kata.avatars.to_a.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '638', %w(
  avatars[invalid-name] is not nil
  because validity is check on use not on creation ) do
    kata = make_language_kata
    refute_nil kata.avatars[nil], 'nil'
    refute_nil kata.avatars['mobile-phone'], 'invalid'
    refute_nil kata.avatars['cheetah'], 'unstarted'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '74D',
  'avatars[panda] is the panda when the panda has started' do
    kata = make_language_kata
    kata.start_avatar([panda])
    assert_equal [panda], kata.avatars.names
    assert_equal panda, katas[kata.id].avatars[panda].name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '350',
  'avatars returns all avatars started in the kata with that id' do
    kata = make_language_kata
    kata.start_avatar([lion])
    kata.start_avatar([hippo])
    expected_names = [lion, hippo]
    actual_names = kata.avatars.names
    assert_equal expected_names.sort, actual_names.sort
  end

end
