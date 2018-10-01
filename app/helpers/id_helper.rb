require_relative '../../lib/phonetic_alphabet'

module IdHelper # mix-in

  module_function

  def partial(id)
    id[0..5]
  end

  def phonetic(id)
    Phonetic.spelling(id).join('-')
  end

end
