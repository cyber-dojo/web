require_relative '../../lib/phonetic_alphabet'

class Group

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  def short_id
    id[0..5]
  end

  def phonetic_short_id
    Phonetic.spelling(short_id).join('-')
  end

  def avatars
    Avatars.new(@externals, id)
  end

end
