
module DashboardWorker # mixin

  module_function

  def gather
    @minute_columns = bool('minute_columns')
    @auto_refresh = bool('auto_refresh')
    @all_lights = {}
    @all_indexes = {}
    e = group.events
    e.each do |kata_id,o|
      kata = katas[kata_id]
      lights = o['events'].each.with_index.map{ |event,index|
        event['index'] = index
        Event.new(kata, event)
      }.select(&:light?)
      unless lights === []
        @all_lights[kata_id] = lights
        @all_indexes[kata_id] = o['index']
      end
    end
    args = [group.created, seconds_per_column, max_seconds_uncollapsed]
    gapper = DashboardTdGapper.new(*args)
    @gapped = gapper.fully_gapped(@all_lights, time.now)
    @time_ticks = gapper.time_ticks(@gapped)
    @age = group.age(e)
    @version = group.schema.version
    set_footer_info
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def set_footer_info
    @group_id = group.id
    @avatar_name = ''
    @display_name = group.manifest.display_name
    @exercise = group.manifest.exercise
  end

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
    group.katas
         .select(&:active?)
         .map { |kata| animal_progress(kata) }
         .to_h
  end

  def animal_progress(kata)
    [kata.avatar_name, {
        colour: kata.lights[-1].colour,
      progress: most_recent_progress(kata),
         index: Avatars.index(kata.avatar_name),
            id: kata.id
    }]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def most_recent_progress(kata)
    non_amber = kata.lights.reverse.find { |light|
      [:red,:green].include?(light.colour)
    }
    if non_amber
      output = non_amber.stdout['content'] + non_amber.stderr['content']
    else
      output = ''
    end

    regexs = kata.manifest.progress_regexs
    matches = regexs.map { |regex| Regexp.new(regex).match(output) }

    {
        text: matches.join,
      colour: (matches[0] != nil ? 'red' : 'green')
    }
  end

end
