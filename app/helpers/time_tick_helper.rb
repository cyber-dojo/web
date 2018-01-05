
module TimeTickHelper # mix-in

  module_function

  def time_tick(seconds)
    minutes = (seconds / 60) % 60
    hours   = (seconds / 60 / 60) % 24
    days    = (seconds / 60 / 60 / 24)

    tick = ''
    if seconds >= SECONDS_PER_DAY
      tick += days.to_s + 'd:'
    end
    if seconds >= SECONDS_PER_HOUR
      tick += hours.to_s + 'h:'
    end
    tick += minutes.to_s + 'm'
  end

  HOURS_PER_DAY = 24
  MINUTES_PER_HOUR = 60
  SECONDS_PER_MINUTE = 60

  SECONDS_PER_HOUR = SECONDS_PER_MINUTE * MINUTES_PER_HOUR
  SECONDS_PER_DAY = SECONDS_PER_HOUR * HOURS_PER_DAY

end
