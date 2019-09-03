require_relative 'app_models_test_base'
require_relative '../../app/models/id_generator'
require 'fileutils'
require 'tmpdir'

class IdGeneratorTest < AppModelsTestBase

  def self.hex_prefix
    'A6D'
  end

  def alphabet
    IdGenerator::alphabet
  end

  # - - - - - - - - - - - - - - - - - - -

  test '064', %w(
  alphabet has 58 characters all of which get used ) do
    assert_equal 58, alphabet.size
    counts = {}
    until counts.size === 58 do
      id_generator.id.each_char do |ch|
        counts[ch] = true
      end
    end
    assert_equal alphabet.chars.sort.join, counts.keys.sort.join
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

  test '066', %w( <new>
  id generation is sufficiently random that there are
  no duplicates in 25,000 repeats ) do
    ids = {}
    repeats = 25000
    repeats.times do
      ids[id_generator.id] = true
    end
    assert repeats, ids.keys.size
  end

  # - - - - - - - - - - - - - - - - - - -

  test '068', %w(
  id?(s) true ) do
    assert id?('012AaEefFgG89Zz')
    assert id?('345BbCcDdEeFfGg')
    assert id?('678HhJjKkMmNnPp')
    assert id?('999PpQqRrSsTtUu')
    assert id?('263VvWwXxYyZz11')
  end

  # - - - - - - - - - - - - - - - - - - -

  test '069', %w(
  id?(s) false ) do
    refute id?(nil)
    refute id?([])
    refute id?(25)
    refute id?('I'), :India
    refute id?('i'), :india
    refute id?('O'), :Oscar
    refute id?('o'), :oscar
  end

  private

  def id?(s)
    IdGenerator::id?(s)
  end

end
