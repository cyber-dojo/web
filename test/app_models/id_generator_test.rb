require_relative 'app_models_test_base'
require_relative '../../app/models/id_generator'
require 'fileutils'
require 'tmpdir'

class IdGeneratorTest < AppModelsTestBase

  def self.hex_prefix
    'A6D'
  end

  def alphabet
    IdGenerator::ALPHABET
  end

  # - - - - - - - - - - - - - - - - - - -

  test 's82', %w(
  alphabet has 58 characters
  ) do
    assert_equal 58, alphabet.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test '063', %w(
  entire alphabet is used in group ids
  ) do
    id_generator = IdGenerator.new(self)
    counts = {}
    until counts.size === 58 do
      id_generator.group_id.each_char do |ch|
        counts[ch] = true
      end
    end
    assert_equal alphabet.chars.sort, counts.keys.sort
  end

  test '064', %w(
  entire alphabet is used in kata ids
  ) do
    id_generator = IdGenerator.new(self)
    counts = {}
    until counts.size === 58 do
      id_generator.kata_id.each_char do |ch|
        counts[ch] = true
      end
    end
    assert_equal alphabet.chars.sort, counts.keys.sort
  end

  # - - - - - - - - - - - - - - - - - - -

  test '065', %w(
  every letter of the alphabet can be used as part of a dir-name
  ) do
    diagnostic = 'forward slash is the dir separator'
    refute alphabet.include?('/'), diagnostic
    diagnostic = 'dot is a dir navigator'
    refute alphabet.include?('.'), diagnostic
    diagnostic = 'single quote to protect all other letters'
    refute alphabet.include?("'"), diagnostic
    alphabet.each_char do |letter|
      path = Dir.mktmpdir("/tmp/#{letter}")
      FileUtils.mkdir_p(path)
      at_exit { FileUtils.remove_entry(path) }
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  test '066', %w(
  kata-id generation is sufficiently random that there are
  no duplicates in 5000 repeats
  ) do
    id_generator = IdGenerator.new(self)
    ids = {}
    repeats = 5000
    repeats.times do
      ids[id_generator.kata_id] = true
    end
    assert_equal repeats, ids.keys.size
  end

  test '067', %w(
  group-id generation is sufficiently random that there are
  no duplicates in 5000 repeats
  ) do
    id_generator = IdGenerator.new(self)
    ids = {}
    repeats = 5000
    repeats.times do
      ids[id_generator.group_id] = true
    end
    assert_equal repeats, ids.keys.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test '13d', %w(
  id 999999 is reserved for a kata id created when saver is offline
  ) do
    @random = Class.new do
      def initialize
        @indexes = [9]*6 + [5]*6
        @n = 0
      end
      def rand(size)
        index = @indexes[@n]
        @n += 1
        index
      end
    end.new
    id_generator = IdGenerator.new(self)
    assert_equal '555555', id_generator.kata_id
  end

  # - - - - - - - - - - - - - - - - - - -

  # - - - - - - - - - - - - - - - - - - -

  test '068', %w(
  id?(s) true
  ) do
    assert id?('012AaE')
    assert id?('345BbC')
    assert id?('678HhJ')
    assert id?('999PpQ')
    assert id?('263VvW')
  end

  # - - - - - - - - - - - - - - - - - - -

  test '069', %w(
  id?(s) false
  ) do
    refute id?(42)
    refute id?(nil)
    refute id?({})
    refute id?([])
    refute id?(25)
    refute id?('I'), :India
    refute id?('i'), :india
    refute id?('O'), :Oscar
    refute id?('o'), :oscar
    refute id?('12345'), :not_length_6
    refute id?('1234567'), :not_length_6
  end

  private

  def id?(s)
    IdGenerator::id?(s)
  end

end
