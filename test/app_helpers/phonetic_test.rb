require_relative 'app_helpers_test_base'

class PhoneticTest < AppHelpersTestBase

  def self.hex_prefix
    '85A03E'
  end

  include PhoneticHelper

  test 'D07',
  'example' do
    assert_equal 'echo-five-KILO-xray-three-nine', phonetic('e5Kx39')
  end

end
