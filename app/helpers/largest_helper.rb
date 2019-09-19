# frozen_string_literal: true

module LargestHelper # mix-in

  module_function

  def largest(visible_files)
    visible_files.max{ |lhs,rhs|
      lhs[1]['content'].size <=> rhs[1]['content'].size
    }[1]['content']
  end

end
