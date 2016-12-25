require_relative './app_models_test_base'

class AvatarsTest < AppModelsTestBase

  def setup
    super
    set_storer_class('FakeStorer')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F149',
  'there are 64 avatar names' do
    assert_equal 64, Avatars.names.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F12F',
  'avatars.each is [] when empty' do
    kata = make_kata
    assert_equal [], kata.avatars.to_a
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6FF79',
  'avatars returns all avatars started in the kata' do
    kata = make_kata
    assert_equal [], kata.avatars.names.sort
    kata.start_avatar([cheetah])
    assert_equal [cheetah], kata.avatars.names.sort
    kata.start_avatar([lion])
    assert_equal [cheetah, lion], kata.avatars.names.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F555',
  'avatars.map works' do
    kata = make_kata
    kata.start_avatar([cheetah])
    kata.start_avatar([lion])
    assert_equal [cheetah, lion], kata.avatars.names.sort
    assert_equal 2, kata.avatars.to_a.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F638',
  'avatars[invalid-name] is nil' do
    kata = make_kata
    assert_nil kata.avatars[invalid_name = 'mobile-phone']
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F429',
  'avatars[cheetah] is nil when cheetah has not started' do
    kata = make_kata
    assert_nil kata.avatars[cheetah]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F74D',
  'avatars[panda] is the panda when the panda has started' do
    kata = make_kata
    kata.start_avatar([panda])
    assert_equal [panda], kata.avatars.names
    assert_equal panda, katas[kata.id].avatars[panda].name
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'B6F350',
  'avatars returns all avatars started in the kata with that id' do
    kata = make_kata
    kata.start_avatar([lion])
    kata.start_avatar([hippo])
    expected_names = [lion, hippo]
    actual_names = kata.avatars.names
    assert_equal expected_names.sort, actual_names.sort
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private

  def cheetah; 'cheetah'; end
  def lion   ; 'lion'   ; end
  def hippo  ; 'hippo'  ; end
  def panda  ; 'panda'  ; end

end
