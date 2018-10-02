
class Avatar

  def initialize(externals, id, index)
    @externals = externals
    @id = id
    @index = index
  end

  def name
    Avatars.names[@index.to_i]
  end

  def kata
    Kata.new(@externals, @id)
  end

end

# Each avatar does _not_ choose their own language+test.
# The language+test is chosen for the group.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
