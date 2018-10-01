
# On the diff dialog/page to cycle through the avatars.

module RingPicker # mix-in

  module_function

  def ring_prev(array, current)
    return '' if array.length == 0
    return '' if array.length == 1
    return array[-1] if array.first == current
    return array[array.rindex(current) - 1]
  end

  def ring_next(array, current)
    return '' if array.length == 0
    return '' if array.length == 1
    return array[0] if array.last == current
    return array[array.index(current) + 1]
  end

end
