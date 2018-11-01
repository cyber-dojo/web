require_relative 'app_helpers_test_base'

class ParityTest < AppHelpersTestBase

  def self.hex_prefix
    '6Az'
  end

  include ParityHelper

  test '185',
  'odd' do
    assert_equal 'odd', parity(1)
    assert_equal 'odd', parity(3)
    assert_equal 'odd', parity(5)
  end

  test '3BA',
  'even' do
    assert_equal 'even', parity(0)
    assert_equal 'even', parity(2)
    assert_equal 'even', parity(4)
  end

end
