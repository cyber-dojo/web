require_relative 'app_helpers_test_base'

class TimeTickTest < AppHelpersTestBase

  include TimeTickHelper

  test '86F600',
  'when days=0,hours=0,mins=0 then nothing is shown' do
    assert_equal '', time_tick( 0)
    assert_equal '', time_tick(59)
  end

  test '86F601',
  'when days=0,hours=0,mins!=0 then minutes are show in 2 digits' do
    assert_equal '01', time_tick(1*60)
    assert_equal '01', time_tick(1*60+4)
    assert_equal '02', time_tick(2*60)
    assert_equal '02', time_tick(2*60+59)
    assert_equal '59', time_tick(59*60)
    assert_equal '59', time_tick(59*60+59)
  end

  test '86F602',
  'when days=0,hours!=0 then hours and minutes are shown in 2 digits' do
    assert_equal '01:00', time_tick(60*60)
    assert_equal '01:00', time_tick(60*60+4)
    assert_equal '01:00', time_tick(60*60+59)
    assert_equal '01:01', time_tick(60*60+60)
    assert_equal '23:59', time_tick(23*60*60 + 59*60)
  end

  test '86F603',
  'when days!=0 then days are shown and hours,minutes are shown in 2 digits' do
    assert_equal '01:00',    time_tick(60*60)
    assert_equal '01:01',    time_tick(61*60)
    assert_equal '1:00:00',  time_tick(1*24*60*60)
    assert_equal '1:00:01',  time_tick(1*24*60*60 + 0*60*60 + 1*60)
    assert_equal '1:00:01',  time_tick(1*24*60*60 + 0*60*60 + 1*60 + 1)
    assert_equal '1:02:01',  time_tick(1*24*60*60 + 2*60*60 + 1*60)
    assert_equal '34:06:24', time_tick(34*24*60*60 + 6*60*60 + 24*60)
    assert_equal '34:06:24', time_tick(34*24*60*60 + 6*60*60 + 24*60 + 56)
  end


end
