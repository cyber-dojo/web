require_relative 'app_models_test_base'
require_relative '../../app/models/base58'

class LightTest < AppModelsTestBase

  def self.hex_prefix
    'B692E'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test 'FB3', 'simple alphabet sanity check' do
    assert_equal 58, Base58.alphabet.size
  end

end
