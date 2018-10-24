
class Group

  def initialize(externals, id)
    @externals = externals
    @id = id
  end

  # - - - - - - - - - - - - -

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
      Avatar.new(kata(kid), index)
    end
  end

  # - - - - - - - - - - - - -

  def size
    katas.size
  end

  # - - - - - - - - - - - - -

  def empty?
    size == 0
  end

  # - - - - - - - - - - - - -

  def katas
    joined.values.map{ |kid| kata(kid) }
  end

  # - - - - - - - - - - - - -

  def age
    ages = katas.select(&:active?).map{ |kata| kata.age }
    ages == [] ? 0 : ages.sort[-1]
  end

  # - - - - - - - - - - - - -

  def manifest
    @manifest ||= Manifest.new(saver.group_manifest(id))
  end

  private

  def kata(kid)
    Kata.new(@externals, kid)
  end

  def joined
    @joined ||= saver.group_joined(id)
  end

  def saver
    @externals.saver
  end

end
