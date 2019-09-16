require_relative '../../lib/base58'

class Group

  def initialize(externals, id, v)
    @externals = externals
    @id = id
    @v = v
  end

  attr_reader :id

  def exists?
    Base58.string?(id) &&
      id.length === 6 &&
        @v.group.exists?(id)
  end

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = (0..63).to_a.shuffle)
    kid = @v.group.join(id, indexes)
    if kid.nil?
      nil
    else
      kata(kid)
    end
  end

  def events
    @v.group.events(id)
  end

  def size
    katas.size
  end

  def empty?
    size == 0
  end

  def katas
    @v.group.joined(id).map{ |kid| kata(kid) }
  end

  def age
    katas.select(&:active?).map{ |kata| kata.age }.sort[-1] || 0
  end

  def manifest
    @manifest ||= Manifest.new(@v.group.manifest(id))
  end

  private

  def kata(kid)
    Kata.new(@externals, kid, @v)
  end

end
