require_relative 'app_models_test_base'

class AvatarsTest < AppModelsTestBase

  def self.hex_prefix
    'B6s'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'there are 64 avatar names' do
    assert_equal 64, Avatars.names.length
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '14A',
  'index of an avatar name' do
    assert_equal  0, Avatars.index('alligator')
    assert_equal 45, Avatars.index('salmon')
    assert_equal 63, Avatars.index('zebra')
  end

end
