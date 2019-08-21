require_relative 'lib_test_base'
require_relative '../../lib/base58'

class Base58Test < TestBase

  def self.hex_prefix
    'F3A'
  end

  # - - - - - - - - - - - - - - - - - - -

  test '068', %w(
  string?(s) true ) do
    assert string?('012AaEefFgG89Zz')
    assert string?('345BbCcDdEeFfGg')
    assert string?('678HhJjKkMmNnPp')
    assert string?('999PpQqRrSsTtUu')
    assert string?('263VvWwXxYyZz11')
  end

  # - - - - - - - - - - - - - - - - - - -

  test '069', %w(
  string?(s) false ) do
    refute string?(nil)
    refute string?([])
    refute string?(25)
    refute string?('I'), 'India'
    refute string?('i'), 'india'
    refute string?('O'), 'Oscar'
    refute string?('o'), 'oscar'
  end

  private

  def string?(s)
    Base58.string?(s)
  end

end
