# frozen_string_literal: true

module TimeTickHelper # mix-in

  module_function

  def time_tick(seconds)
    hours_per_day = 24
    minutes_per_hour = 60
    seconds_per_minute = 60

    seconds_per_hour = seconds_per_minute * minutes_per_hour
    seconds_per_day = seconds_per_hour * hours_per_day

    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)

    tick = ''
    if seconds >= seconds_per_day
      d = "<span class='d-for-days'>d</span>"
      tick += days.to_s + d + '&thinsp;'
    end
    if seconds >= seconds_per_hour
      h = "<span class='h-for-hours'>h</span>"
      tick += hours.to_s + h + '&thinsp;'
    end
    m = "<span class='m-for-minutes'>m</span>"
    tick += minutes.to_s + m
  end

end
