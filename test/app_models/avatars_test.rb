require_relative 'app_models_test_base'

class AvatarsTest < AppModelsTestBase

  def self.hex_prefix
    'B6s'
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '149',
  'there are 64 avatar names' do
    assert_equal 64, Avatars.names.length
    assert_equal 'alligator', Avatars.names[0]
    assert_equal 'salmon', Avatars.names[45]
    assert_equal 'zebra', Avatars.names[63]
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '150',
  'use the avatars index to get its image' do
    (0..63).each do |i|
      assert_equal i, Avatars.index(Avatars.names[i]), i
    end
  end

end
