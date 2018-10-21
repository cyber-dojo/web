
class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  def id
    @id
  end

  # - - - - - - - - - - - - -

  def exists?
    if id == ''
      false
    else
      @exists ||= saver.group_exists?(id)
    end
  end

  # - - - - - - - - - - - - -

  def join(indexes = (0..63).to_a.shuffle)
    index,kid = saver.group_join(id, indexes)
    if index.nil?
      nil
    else
      Avatar.new(kata_for(index, kid), index)
    end
  end

  # - - - - - - - - - - - - -

  def katas
    joined.map{ |index,kid| kata_for(index, kid) }
  end

  # - - - - - - - - - - - - -

  def avatars
    Hash[joined.map{ |index,kid|
      kata = kata_for(index, kid)
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
    @manifest ||= Manifest.new(saver.group_manifest(id))
  end

  private

  attr_reader :externals

  def kata_for(index, kid)
    Kata.new(externals, kid, [self,index])
  end

  def joined
    @joined ||= saver.group_joined(id)
  end

  def saver
    externals.saver
  end

end
