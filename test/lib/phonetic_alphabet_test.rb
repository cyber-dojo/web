require_relative 'lib_test_base'
require_relative '../../lib/phonetic_alphabet'

class PhoneticAlphabetTest < LibTestBase

  def self.hex_prefix
    '181'
  end

  # - - - - - - - - - - - - - -

  test '3D2', 'spelling' do
    expected = %w( UNIFORM two mike PAPPA quebec )
    assert_equal expected, Phonetic.spelling('U2mPq')
  end

  # - - - - - - - - - - - - - -

  test '3D3', 'digits' do
     digits = %w(
      0 zero
      1 one
      2 two
      3 three
      4 four
      5 five
      6 six
      7 seven
      8 eight
      9 nine
    )
    phonetic_test(digits)
    assert_equal 10*2, digits.size
  end

  # - - - - - - - - - - - - - -

  test '3D4', 'uppercase' do
    uppercase = %w(
      A ALPHA
      B BRAVO
      C CHARLIE
      D DELTA
      E ECHO
      F FOXTROT
      G GOLF
      H HOTEL
      I INDIA
      J JULIETT
      K KILO
      L LIMA
      M MIKE
      N NOVEMBER
      O OSCAR
      P PAPPA
      Q QUEBEC
      R ROMEO
      S SIERRA
      T TANGO
      U UNIFORM
      V VICTOR
      W WHISKEY
      X XRAY
      Y YANKEE
      Z ZULU
    )
    phonetic_test(uppercase)
    assert_equal 26*2, uppercase.size
  end

  # - - - - - - - - - - - - - -

  test '3D5', 'lowercase' do
    lowercase = %w(
      a alpha
      b bravo
      c charlie
      d delta
      e echo
      f foxtrot
      g golf
      h hotel
      i india
      j juliett
      k kilo
      l lima
      m mike
      n november
      o oscar
      p pappa
      q quebec
      r romeo
      s sierra
      t tango
      u uniform
      v victor
      w whiskey
      x xray
      y yankee
      z zulu
    )
    phonetic_test(lowercase)
    assert_equal 26*2, lowercase.size
  end

  private

  def phonetic_test(data)
    data.each_slice(2) do |ch,expected|
      assert_equal expected, Phonetic.letter(ch)
    end
  end

end
