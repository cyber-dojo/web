# frozen_string_literal: true

require_relative '../../lib/phonetic_alphabet'

module PhoneticHelper # mix-in

  module_function

  def phonetic(id)
    Phonetic.spelling(id).join('-')
  end

end
