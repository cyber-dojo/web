
class Avatar

  def initialize(externals, id, name)
    # Does *not* validate.
    @externals = externals
    @id = id
    @name = name
  end

  attr_reader :name

  def kata
    Kata.new(@externals, @id)
  end

  def active?
    kata.active?
  end

end
