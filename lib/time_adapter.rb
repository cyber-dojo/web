# frozen_string_literal: true

class TimeAdapter

  def now
    t = Time.now
    [t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec]
  end

end
