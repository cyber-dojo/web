# frozen_string_literal: true

module ParityHelper # mix-in

  module_function

  def parity(n)
    n.odd? ? 'odd' : 'even'
  end

end
