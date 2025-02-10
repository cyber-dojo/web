require_relative 'lib_test_base'
require_relative '../../lib/time_adapter'

class TimeAdapterTest < LibTestBase

  def self.hex_prefix
    'x81'
  end

  # - - - - - - - - - - - - - -

  test '9F0',
  'now returns 7 integers to make a Time from' do
    time = TimeAdapter.new
    now1 = time.now
    assert now1.is_a?(Array)
    assert_equal 7, now1.size
    assert now1.all?{|e| e.is_a?(Integer)}
    now2 = Time.now
    duration = Time.mktime(*now2) - Time.mktime(*now1)
    assert duration.is_a?(Float)
  end

end
