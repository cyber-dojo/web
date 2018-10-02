require_relative 'app_lib_test_base'

class RingPickerTest < AppLibTestBase

  def self.hex_prefix
    '9A996B'
  end

  include RingPicker

  def hex_setup
    set_differ_class('NotUsed')
    set_runner_class('NotUsed')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '099',
  'previous when single entry is empty string' do
    assert_prev('a', %w{ a }, '')
  end

  test '3BA',
  'previous in two entries' do
    assert_prev('a', %w{ a b }, 'b')
    assert_prev('b', %w{ a b }, 'a')
  end

  test '085',
  'previous in three entries' do
    assert_prev('a', %w{ a b c }, 'c')
    assert_prev('b', %w{ a b c }, 'a')
    assert_prev('c', %w{ a b c }, 'b')
  end

  test '41B',
  'previous in four entries' do
    assert_prev('a', %w{ a b c d }, 'd')
    assert_prev('b', %w{ a b c d }, 'a')
    assert_prev('c', %w{ a b c d }, 'b')
    assert_prev('d', %w{ a b c d }, 'c')
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - -

  test '549',
  'next when single entry is empty string' do
    assert_next('a', %w{ a }, '')
  end

  test '283',
  'next in two entries' do
    assert_next('a', %w{ a b }, 'b')
    assert_next('b', %w{ a b }, 'a')
  end

  test '3EF',
  'next in three entries' do
    assert_next('a', %w{ a b c }, 'b')
    assert_next('b', %w{ a b c }, 'c')
    assert_next('c', %w{ a b c }, 'a')
  end

  test '6FB',
  'next in four entries' do
    assert_next('a', %w{ a b c d }, 'b')
    assert_next('b', %w{ a b c d }, 'c')
    assert_next('c', %w{ a b c d }, 'd')
    assert_next('d', %w{ a b c d }, 'a')
  end

  private

  def assert_prev(arg, entries, expected)
    clone = entries.clone
    assert_equal expected, ring_prev(clone, arg)
    assert_equal clone, entries
  end

  def assert_next(arg, entries, expected)
    clone = entries.clone
    assert_equal expected, ring_next(clone, arg)
    assert_equal clone, entries
  end

end
