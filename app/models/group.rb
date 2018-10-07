
class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  def exists?
    @exists ||= grouper.exists?(@id)
  end

  # - - - - - - - - - - - - -

  def katas
    joined.map{ |index,sid|
      Kata.new(@externals, sid, [self,index])
    }
  end

  def avatars
    Hash[joined.map{ |index,sid|
      kata = Kata.new(@externals, sid)
      name = Avatars.names[index.to_i]
      [name, Avatar.new(kata, index)]
    }]
  end

  # - - - - - - - - - - - - -

  def age
    ages = katas.select(&:active?).map{ |kata| kata.age }
    ages == [] ? 0 : ages.sort[-1]
  end

  def manifest
    @manifest ||= Manifest.new(grouper.manifest(id))
  end

  private

  def joined
    @joined ||= grouper.joined(id)
  end

  def grouper
    @externals.grouper
  end

end

# The language+test is chosen for the group.
# cyber-dojo is a team-based Interactive Dojo Environment,
# not an Individual Development Environment
