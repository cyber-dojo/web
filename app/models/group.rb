require_relative '../../lib/base58'
require_relative 'group_v1'

class Group

  def initialize(externals, id)
    @v = Group_v1.new(externals)
    @externals = externals
    @id = id
  end

  attr_reader :id

  def exists?
    Base58.string?(id) &&
      id.length === 6 &&
        @v.exists?(id)
  end

  def created
    Time.mktime(*manifest.created)
  end

  def join(indexes = (0..63).to_a.shuffle)
    kid = @v.join(id, indexes)
    if kid.nil?
      nil
    else
      kata(kid)
    end
  end

  def events
    @v.events(id)
  end

  def size
    katas.size
  end

  def empty?
    size == 0
  end

  def katas
    @v.joined(id).map{ |kid| kata(kid) }
  end

  def age
    katas.select(&:active?).map{ |kata| kata.age }.sort[-1] || 0
  end

  def manifest
    @manifest ||= Manifest.new(@v.manifest(id))
  end

  private

  def kata(kid)
    Kata.new(@externals, kid)
  end

end
