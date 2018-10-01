
# On the diff dialog/page to cycle through the avatars.

module RingPicker # mix-in

  module_function

  def ring_prev(array, current)
    if array.length < 2
      ''
    elsif array[0] == current
      array[-1]
    else
      array[array.index(current) - 1]
    end
  end

  def ring_next(array, current)
    if array.length < 2
      ''
    elsif array[-1] == current
      array[0]
    else
      array[array.index(current) + 1]
    end
  end

end
