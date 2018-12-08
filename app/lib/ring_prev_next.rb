
# On the review dialog/page to cycle through the avatars.

module RingPrevNext # mix-in

  module_function

  # - - - - - - - - - - - - - - - -

  def ring_prev_next(kata)
    if kata.group
      indexes = []
      # using saver.group_events() BatchMethod      
      saver.group_events(kata.group.id).each do |kata_id,o|
        if o['events'].any?{ |event| event.has_key?('colour') }
          indexes << { index: o['index'], id: kata_id }
        end
      end
      active = indexes.sort{ |lhs,rhs| lhs[:index] <=> rhs[:index] }
    else
      active = []
    end

    size = active.size
    i = active.index { |k| k[:index] == kata.manifest.group_index }
    if i && size > 1
      [ active[i-1][:id], active[(i+1) % size][:id] ]
    else
      [ '', '' ]
    end
  end

end
