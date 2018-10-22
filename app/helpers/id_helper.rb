require_relative '../../lib/phonetic_alphabet'

module IdHelper # mix-in

  module_function

  def phonetic(id)
    Phonetic.spelling(id).join('-')
  end

end
