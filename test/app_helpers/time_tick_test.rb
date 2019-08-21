require_relative 'app_helpers_test_base'

class TimeTickTest < AppHelpersTestBase

  def self.hex_prefix
    '8r6'
  end

  include TimeTickHelper

  test '600', %w(
  when days=0,hours=0,mins=0
  then seconds are not shown
  and 0m is shown ) do
    assert_equal m(0), time_tick( 0)
    assert_equal m(0), time_tick(59)
  end

  # - - - - - - - - - - - - - - - - -

  test '601', %w(
  when days=0,hours=0,mins!=0
  then minutes are show with m suffix ) do
    assert_equal m(1), time_tick(1*60)
    assert_equal m(1), time_tick(1*60+4)
    assert_equal m(2), time_tick(2*60)
    assert_equal m(2), time_tick(2*60+59)
    assert_equal m(59), time_tick(59*60)
    assert_equal m(59), time_tick(59*60+59)
  end

  # - - - - - - - - - - - - - - - - -

  test '602', %w(
  when days=0,hours!=0
  then hours are show with h suffix
  and minutes are shown with m suffix
  separated by a colon ) do
    assert_equal hm(1,0), time_tick(60*60)
    assert_equal hm(1,0), time_tick(60*60+4)
    assert_equal hm(1,0), time_tick(60*60+59)
    assert_equal hm(1,1), time_tick(60*60+60)
    assert_equal hm(23,59), time_tick(23*60*60 + 59*60)
  end

  # - - - - - - - - - - - - - - - - -

  test '603', %w(
  when days!=0
  then days,hours,minutes are shown with d,h,m suffixes ) do
    assert_equal dhm(1,0,0),  time_tick(1*24*60*60)
    assert_equal dhm(1,0,1),  time_tick(1*24*60*60 + 0*60*60 + 1*60)
    assert_equal dhm(1,0,1),  time_tick(1*24*60*60 + 0*60*60 + 1*60 + 1)
    assert_equal dhm(1,2,1),  time_tick(1*24*60*60 + 2*60*60 + 1*60)
    assert_equal dhm(34,6,24), time_tick(34*24*60*60 + 6*60*60 + 24*60)
    assert_equal dhm(34,6,24), time_tick(34*24*60*60 + 6*60*60 + 24*60 + 56)
  end

  # - - - - - - - - - - - - - - - - -

  def m(value)
    "#{value}<span class='m-for-minutes'>m</span>"
  end

  def hm(h,m)
    [
      "#{h}<span class='h-for-hours'>h</span>",
      '&thinsp;',
      "#{m}<span class='m-for-minutes'>m</span>"
    ].join
  end

  def dhm(d, h , m)
    [
      "#{d}<span class='d-for-days'>d</span>",
      '&thinsp;',
      "#{h}<span class='h-for-hours'>h</span>",
      '&thinsp;',
      "#{m}<span class='m-for-minutes'>m</span>"
    ].join
  end

end
