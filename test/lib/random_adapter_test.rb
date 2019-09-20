require_relative 'lib_test_base'
require_relative '../../lib/random_adapter'

class RandomAdapterTest < LibTestBase

  def self.hex_prefix
    'aC0'
  end

  # - - - - - - - - - - - - - -

  test '067',
  'rand(n) returns all Integers between 0 (inclusive) and n (exclusive)' do
    number = RandomAdapter.new
    counts = {}
    until counts.size === 6
      i = number.rand(6)
      assert i.is_a?(Integer)
      assert i >= 0
      assert i < 6
      counts[i] = true
    end
  end

end
