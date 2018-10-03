require_relative '../../lib/time_now'

module DashboardWorker # mixin

  module_function

  def gather
    @group = groups[id]
    @minute_columns = bool('minute_columns')
    @auto_refresh = bool('auto_refresh')
    @all_lights = Hash[
      @group.katas
           .select(&:active?)
           .map{ |kata| [kata.avatar.name, kata.lights] }
    ]
    args = [@group.manifest.created, seconds_per_column, max_seconds_uncollapsed]
    gapper = DashboardTdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time_now)
    @time_ticks = gapper.time_ticks(@gapped)
  end

  include TimeNow

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def bool(attribute)
    tf = params[attribute]
    (tf == 'false') ? tf : 'true'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def seconds_per_column
    flag = params['minute_columns']
    # default is that time-gaps are on
    return 60 if flag.nil? || flag == 'true'
    return 60*60*24*365*1000
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def max_seconds_uncollapsed
    seconds_per_column * 5
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def animals_progress
    Hash[groups[id].katas
              .select(&:active?)
              .map { |kata| [
                kata.avatar.name, {
                  colour: kata.lights[-1].colour,
                progress: most_recent_progress(kata)
              }]}]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def most_recent_progress(kata)
    regexs = kata.manifest.progress_regexs
    non_amber = kata.lights.reverse.find{ |light|
      [:red,:green].include?(light.colour)
    }
    output = (non_amber != nil) ? non_amber.output : ''
    matches = regexs.map { |regex|
      Regexp.new(regex).match(output)
    }
    {
        text: matches.join,
      colour: (matches[0] != nil ? 'red' : 'green')
    }
  end

end
