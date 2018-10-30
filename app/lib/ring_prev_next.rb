
# On the review dialog/page to cycle through the avatars.

module RingPrevNext # mix-in

  module_function

  # - - - - - - - - - - - - - - - -

  def ring_prev_next(kata)
    if kata.group
      active = kata.group
                   .katas
                   .select(&:active?)
                   .sort_by(&:avatar_name)
    else
      active = []
    end

    size = active.size
    i = active.index{ |k| k.avatar_name == kata.avatar_name }
    if i
      [ active[i-1].id, active[(i+1) % size].id ]
    else
      [ '', '' ]
    end
  end

end
