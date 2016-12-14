require_relative './app_lib_test_base'

class RingPickerTest < AppLibTestBase

  include RingPicker

  def setup
    super
    set_storer_class('NotUsed')
    set_runner_class('NotUsed')
    set_differ_class('NotUsed')
  end

  #------------------------------------------------------------------

  test '9A9099',
  'previous when single entry is empty string' do
    assert_prev('a', %w{ a }, '')
  end

  test 'F763BA',
  'previous in two entries' do
    assert_prev('a', %w{ a b }, 'b')
    assert_prev('b', %w{ a b }, 'a')
  end

  test '5CE085',
  'previous in three entries' do
    assert_prev('a', %w{ a b c }, 'c')
    assert_prev('b', %w{ a b c }, 'a')
    assert_prev('c', %w{ a b c }, 'b')
  end

  test 'BC341B',
  'previous in four entries' do
    assert_prev('a', %w{ a b c d }, 'd')
    assert_prev('b', %w{ a b c d }, 'a')
    assert_prev('c', %w{ a b c d }, 'b')
    assert_prev('d', %w{ a b c d }, 'c')
  end

  #------------------------------------------------------------------

  test 'DA1549',
  'next when single entry is empty string' do
    assert_next('a', %w{ a }, '')
  end

  test '90C283',
  'next in two entries' do
    assert_next('a', %w{ a b }, 'b')
    assert_next('b', %w{ a b }, 'a')
  end

  test '88F3EF',
  'next in three entries' do
    assert_next('a', %w{ a b c }, 'b')
    assert_next('b', %w{ a b c }, 'c')
    assert_next('c', %w{ a b c }, 'a')
  end

  test 'ADE6FB',
  'next in four entries' do
    assert_next('a', %w{ a b c d }, 'b')
    assert_next('b', %w{ a b c d }, 'c')
    assert_next('c', %w{ a b c d }, 'd')
    assert_next('d', %w{ a b c d }, 'a')
  end

  #------------------------------------------------------------------

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
