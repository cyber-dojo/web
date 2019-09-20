# frozen_string_literal: true

class Phonetic

  def self.spelling(s)
    s.chars.map { |ch| letter(ch) }
  end

  def self.letter(ch)
    alphabet[ch]
  end

  private

  def self.alphabet
    ALPHABET
  end

  ALPHABET = {
    '0' => 'zero',
    '1' => 'one',
    '2' => 'two',
    '3' => 'three',
    '4' => 'four',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'eight',
    '9' => 'nine',

    'A' => 'ALPHA',
    'B' => 'BRAVO',
    'C' => 'CHARLIE',
    'D' => 'DELTA',
    'E' => 'ECHO',
    'F' => 'FOXTROT',
    'G' => 'GOLF',
    'H' => 'HOTEL',
    'I' => 'INDIA',
    'J' => 'JULIETT',
    'K' => 'KILO',
    'L' => 'LIMA',
    'M' => 'MIKE',
    'N' => 'NOVEMBER',
    'O' => 'OSCAR',
    'P' => 'PAPPA',
    'Q' => 'QUEBEC',
    'R' => 'ROMEO',
    'S' => 'SIERRA',
    'T' => 'TANGO',
    'U' => 'UNIFORM',
    'V' => 'VICTOR',
    'W' => 'WHISKEY',
    'X' => 'XRAY',
    'Y' => 'YANKEE',
    'Z' => 'ZULU',


    'a' => 'alpha',
    'b' => 'bravo',
    'c' => 'charlie',
    'd' => 'delta',
    'e' => 'echo',
    'f' => 'foxtrot',
    'g' => 'golf',
    'h' => 'hotel',
    'i' => 'india',
    'j' => 'juliett',
    'k' => 'kilo',
    'l' => 'lima',
    'm' => 'mike',
    'n' => 'november',
    'o' => 'oscar',
    'p' => 'pappa',
    'q' => 'quebec',
    'r' => 'romeo',
    's' => 'sierra',
    't' => 'tango',
    'u' => 'uniform',
    'v' => 'victor',
    'w' => 'whiskey',
    'x' => 'xray',
    'y' => 'yankee',
    'z' => 'zulu'
  }

end
