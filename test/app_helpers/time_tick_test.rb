require_relative 'app_helpers_test_base'

class TimeTickTest < AppHelpersTestBase

  def self.hex_prefix
    '86F491'
  end

  include TimeTickHelper

  test '600', %w(
  when days=0,hours=0,mins=0
  then seconds are not show
  and 0m is shown ) do
    assert_equal '0m', time_tick( 0)
    assert_equal '0m', time_tick(59)
  end

  # - - - - - - - - - - - - - - - - -

  test '601', %w(
  when days=0,hours=0,mins!=0
  then minutes are show with m suffix ) do
    assert_equal '1m', time_tick(1*60)
    assert_equal '1m', time_tick(1*60+4)
    assert_equal '2m', time_tick(2*60)
    assert_equal '2m', time_tick(2*60+59)
    assert_equal '59m', time_tick(59*60)
    assert_equal '59m', time_tick(59*60+59)
  end

  # - - - - - - - - - - - - - - - - -

  test '602', %w(
  when days=0,hours!=0
  then hours are show with h suffix
  and minutes are shown with m suffix
  separated by a colon ) do
    assert_equal '1h:0m', time_tick(60*60)
    assert_equal '1h:0m', time_tick(60*60+4)
    assert_equal '1h:0m', time_tick(60*60+59)
    assert_equal '1h:1m', time_tick(60*60+60)
    assert_equal '23h:59m', time_tick(23*60*60 + 59*60)
  end

  # - - - - - - - - - - - - - - - - -

  test '603', %w(
  when days!=0
  then days are shown with a d suffix
  and hours are shown with a h suffix
  and minutes are shown with an m suffix ) do
    assert_equal '1d:0h:0m',  time_tick(1*24*60*60)
    assert_equal '1d:0h:1m',  time_tick(1*24*60*60 + 0*60*60 + 1*60)
    assert_equal '1d:0h:1m',  time_tick(1*24*60*60 + 0*60*60 + 1*60 + 1)
    assert_equal '1d:2h:1m',  time_tick(1*24*60*60 + 2*60*60 + 1*60)
    assert_equal '34d:6h:24m', time_tick(34*24*60*60 + 6*60*60 + 24*60)
    assert_equal '34d:6h:24m', time_tick(34*24*60*60 + 6*60*60 + 24*60 + 56)
  end

end
