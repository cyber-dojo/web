
module TimeTickHelper # mix-in

  module_function

  def time_tick(seconds)
    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)

    hours_per_day = 24;
    minutes_per_hour = 60
    seconds_per_minute = 60;
    seconds_per_hour = seconds_per_minute * minutes_per_hour;
    seconds_per_day = seconds_per_hour * hours_per_day;

    tick = ''
    if seconds >= seconds_per_day
      tick += days.to_s + ':'
    end
    if seconds >= seconds_per_hour
      tick += ('%02d' % hours) + ':'
    end
    if seconds >= seconds_per_minute
      tick += ('%02d' % minutes)
    end
    tick
  end

end
