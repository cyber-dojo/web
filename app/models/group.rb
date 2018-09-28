
class Group

  def initialize(externals, id)
    # Does *not* validate.
    @externals = externals
    @id = id
  end

  def id
    @id
  end

end
